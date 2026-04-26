import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/weather.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  final Weather? currentWeather;

  ChatCubit({this.currentWeather}) : super(const ChatState(messages: [])) {
    if (currentWeather != null) {
      _sendWelcome();
    }
  }

  void _sendWelcome() {
    final w = currentWeather!;
    emit(
      state.copyWith(
        messages: [
          ChatMessage(
            text:
                'Salom! Men OSMON AI yordamchisiman 🌤️\n\n'
                'Hozir ${w.city}da ${w.condition}, harorat ${w.temp}°C.\n\n'
                'Ob-havo haqida savollaringiz bormi?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    emit(
      state.copyWith(
        messages: [...state.messages, userMsg],
        isLoading: true,
      ),
    );

    try {
      final reply = await _askGemini(trimmed);
      final botMsg = ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      emit(
        state.copyWith(
          messages: [...state.messages, botMsg],
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            ChatMessage(
              text:
                  'Kechirasiz, javob olishda xatolik yuz berdi. Qayta urinib ko\'ring.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
          isLoading: false,
        ),
      );
    }
  }

  Future<String> _askGemini(String userText) async {
    final String weatherCtx;
    if (currentWeather != null) {
      final w = currentWeather!;
      weatherCtx =
          'Hozirgi ob-havo ma\'lumotlari: ${w.city}, harorat ${w.temp}°C '
          '(sezilayotgan ${w.feelsLike}°C), holat: ${w.condition}, '
          'namlik: ${w.humidity}%, shamol: ${w.windSpeed} km/soat, '
          'AQI: ${w.aqi}.\n\n';
    } else {
      weatherCtx = '';
    }

    final prompt =
        '${weatherCtx}Sen ob-havo yordamchisisisan. '
        'Faqat ob-havo va unga bog\'liq mavzularda yordam ber. '
        'O\'zbek tilida aniq va to\'liq javob ber. '
        'Markdown ishlatma. Emoji ishlatishingiz mumkin.\n\n'
        'Foydalanuvchi: $userText';

    final response = await http
        .post(
          Uri.parse(
            '${ApiConstants.geminiApiUrl}?key=${ApiConstants.geminiApiKey}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 1024,
            },
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      return text?.trim() ?? 'Javob olishda xatolik';
    }
    throw Exception('status: ${response.statusCode}');
  }
}
