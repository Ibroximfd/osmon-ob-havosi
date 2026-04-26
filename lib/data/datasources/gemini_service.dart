import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/weather.dart';
import '../../core/constants/api_constants.dart';

class GeminiAdvice {
  final String advice;
  final String agriculture;
  const GeminiAdvice({required this.advice, required this.agriculture});
}

class GeminiService {
  final _log = Logger();
  static const _cacheDuration = Duration(minutes: 30);

  String _cacheKey(Weather w) =>
      'gemini_v2_${w.city}_${w.temp}_${w.condition}';

  Future<GeminiAdvice?> getCachedAdvice(Weather weather) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(weather);
    final ts = prefs.getInt('${key}_ts') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age < _cacheDuration.inMilliseconds) {
      final advice = prefs.getString('${key}_advice');
      final agri = prefs.getString('${key}_agri');
      if (advice != null && agri != null) {
        return GeminiAdvice(advice: advice, agriculture: agri);
      }
    }
    return null;
  }

  Future<GeminiAdvice?> fetchAdviceInBackground(Weather weather) async {
    try {
      final advicePrompt =
          "Ob-havo ma'lumotlari: ${weather.city}, harorat ${weather.temp}°C "
          "(sezilayotgan ${weather.feelsLike}°C), holat: ${weather.condition}, "
          "namlik: ${weather.humidity}%, shamol: ${weather.windSpeed.toStringAsFixed(1)} km/soat, "
          "AQI: ${weather.aqi}.\n\n"
          "Foydalanuvchiga o'zbek tilida 4 ta qisqa va aniq gap yozing. "
          "Har bir gap aniq foyda bersin, hech qanday salom yoki kirish so'zsiz. "
          "QAT'IY QOIDALAR:\n"
          "- 'Salom', 'Assalomu alaykum', 'Hurmatli foydalanuvchi', 'do'stlar' kabi murojaatlardan FOYDALANMANG\n"
          "- 'OSMON sizga...', 'biz sizga...' kabi marketing iboralarini YOZMANG\n"
          "- Ob-havoni umumiy ta'riflash o'rniga ANIQ harakatlarni ayting\n"
          "- Har gap bitta aniq tavsiya bo'lsin\n\n"
          "Mavzular (har bittasiga 1 gap):\n"
          "1) Kiyim — aniq nima kiyish kerak (futbolka, kurtka, sharf, etik va h.k.)\n"
          "2) Tashqaridagi e'tibor — soyabon, ko'zoynak, niqob, krem va h.k.\n"
          "3) Faoliyat — bugun nima qilish yaxshi (sayr, sport, uyda qolish, suzish)\n"
          "4) Sog'liq — suv ichish, issiq ichimlik, ehtiyot chorasi\n\n"
          "Har gapni emoji bilan boshlang. Markdown ishlatmang.";

      final agriPrompt =
          "Ob-havo: ${weather.city}, harorat ${weather.temp}°C, "
          "namlik: ${weather.humidity}%, shamol: ${weather.windSpeed.toStringAsFixed(1)} km/soat, "
          "holat: ${weather.condition}.\n"
          "Dehqonlar uchun 2 ta aniq amaliy maslahat yozing: sug'orish, ekish yoki parvarish haqida. "
          "Salom va kirish so'zsiz, to'g'ridan-to'g'ri. O'zbek tilida. Emoji bilan.";

      final results = await Future.wait([
        _generate(advicePrompt),
        _generate(agriPrompt),
      ]);

      if (results[0].isEmpty && results[1].isEmpty) return null;

      final advice = GeminiAdvice(
        advice: results[0].isNotEmpty ? results[0] : '',
        agriculture: results[1].isNotEmpty ? results[1] : '',
      );

      // Keshga saqlash
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKey(weather);
      await prefs.setString('${key}_advice', advice.advice);
      await prefs.setString('${key}_agri', advice.agriculture);
      await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);

      return advice;
    } catch (_) {
      return null;
    }
  }

  Future<String> _generate(String prompt) async {
    try {
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
                    {'text': prompt}
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.9,
                'maxOutputTokens': 1024,
                'topP': 0.95,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String?;
        return text?.trim() ?? '';
      }
      _log.w('Gemini ${response.statusCode}: fon maslahat olinmadi');
      return '';
    } catch (_) {
      return '';
    }
  }

  // Eski metodlar — boshqa joylar ishlatsa buzilmasin
  Future<String> getAIWeatherAdvice(Weather weather) async => '';
  Future<String> getAgricultureAdvice(Weather weather) async => '';
}
