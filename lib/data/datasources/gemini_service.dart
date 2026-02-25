import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../domain/entities/weather.dart';
import '../../core/constants/api_constants.dart';

class GeminiService {
  final _log = Logger();

  Future<String> _generateContent(String prompt) async {
    _log.i('Gemini — so\'rov yuborilmoqda...');
    _log.d('Gemini prompt:\n$prompt');

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
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 1024},
            }),
          )
          .timeout(const Duration(seconds: 15));

      _log.i('Gemini javob — status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text']
                as String?;
        _log.i('Gemini matn: $text');
        return text?.trim() ?? '';
      } else {
        _log.e('Gemini xatolik statusi: ${response.statusCode}');
        _log.e('Gemini javob body: ${response.body}');
        return '';
      }
    } catch (e, st) {
      _log.e('Gemini so\'rov istisno', error: e, stackTrace: st);
      return '';
    }
  }

  Future<String> getAIWeatherAdvice(Weather weather) async {
    final prompt =
        "Siz O'zbekiston uchun 'OSMON' ob-havo ilovasining aqlli va do'stona yordamchisisiz. "
        "Hozir ${weather.city}da ob-havo: harorat ${weather.temp}°C (his qilish ${weather.feelsLike}°C), "
        "holat: ${weather.condition}, namlik: ${weather.humidity}%, shamol tezligi: ${weather.windSpeed} km/soat.\n\n"
        "Shu ma'lumotlardan foydalanib, foydalanuvchiga amaliy maslahat bering:\n"
        "• Bugun qanday kiyinish kerak?\n"
        "• Qanday ishlar/faoliyatlar bilan shug‘ullanish yaxshi (yurish, sport, sayr, uyda qolish va h.k.)?\n"
        "• Qo‘shimcha ehtiyot choralari kerakmi?\n\n"
        "Javobni tabiiy, do‘stona va foydali uslubda yozing. "
        "Faqat o'zbek tilida. Maksimal 5 ta gapdan oshirmang.";

    final result = await _generateContent(prompt);
    return result.isNotEmpty
        ? result
        : "Bugun ob-havo sharoitiga mos kiyining va ehtiyot bo'ling.";
  }

  Future<String> getAgricultureAdvice(Weather weather) async {
    final prompt =
        "Siz O'zbekiston qishloq xo'jaligi bo'yicha ob-havo maslahatchisisiz. "
        "Hozir ${weather.city}da harorat ${weather.temp}°C, namlik: ${weather.humidity}%, "
        "shamol: ${weather.windSpeed} km/s, holat: ${weather.condition}. "
        "Dehqonlar uchun bugungi ob-havoga qarab qisqa maslahat bering. Maksimal 2 gap. Faqat o'zbek tilida.";

    final result = await _generateContent(prompt);
    return result.isNotEmpty
        ? result
        : "Havo sharoitiga qarab sug'orish va ekin rejimini moslashtiring.";
  }
}
