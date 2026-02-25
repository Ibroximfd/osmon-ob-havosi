import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../core/constants/api_constants.dart';

class AiPhotoService {
  static final _log = Logger();

  // Tahlil uchun — gemini-2.0-flash (multimodal, alohida kvota)
  static const String _analyzeUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Rasm tahrirlash uchun (pullik API kaliti kerak)
  static const String _imageGenUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent';

  /// [imageFile] — tanlangan rasm fayli
  /// [prompt] — foydalanuvchi yozgan tahrirlash amri
  /// Returns edited image bytes or null on failure
  Future<Uint8List?> editImage({
    required File imageFile,
    required String prompt,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final mimeType = _getMimeType(imageFile.path);

      _log.i('AI Foto: so\'rov yuborilmoqda...');
      _log.d(
        'AI Foto: prompt="$prompt", mime=$mimeType, size=${imageBytes.lengthInBytes} bytes',
      );

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': mimeType, 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'responseModalities': ['Text', 'Image'],
        },
      });

      final response = await http
          .post(
            Uri.parse('$_imageGenUrl?key=${ApiConstants.geminiApiKey}'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      _log.i('AI Foto: javob status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;

        if (parts == null) {
          _log.w('AI Foto: parts null keldi');
          return null;
        }

        for (final part in parts) {
          if (part['inlineData'] != null) {
            final imgData = part['inlineData']['data'] as String;
            _log.i('AI Foto: rasm muvaffaqiyatli tahrirlandi!');
            return base64Decode(imgData);
          }
        }

        _log.w('AI Foto: javobda rasm topilmadi.');
        return null;
      } else if (response.statusCode == 429) {
        _log.e('AI Foto: kvota tugagan (429)');
        return null;
      } else {
        _log.e('AI Foto: xatolik status=${response.statusCode}');
        _log.e('AI Foto: body=${response.body}');
        return null;
      }
    } catch (e, st) {
      _log.e('AI Foto: exception', error: e, stackTrace: st);
      return null;
    }
  }

  /// Faylni tasvir va matn sifatida tasvirlab berish (image understanding)
  Future<String?> analyzeImage({required File imageFile}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final mimeType = _getMimeType(imageFile.path);

      _log.i('AI Foto: tahlil so\'rovi...');

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    "Siz ob-havo ilovasi yordamchisisiz. Bu rasmni tahlil qiling va ob-havoga oid ma'lumotlarni o'zbek tilida qisqacha ayting: qanday ob-havo ko'rinmoqda, harorat taxminan qancha, ehtimol qaysi joy. Maksimal 3-4 gap.",
              },
              {
                'inline_data': {'mime_type': mimeType, 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': 512, 'temperature': 0.7},
      });

      final response = await http
          .post(
            Uri.parse('$_analyzeUrl?key=${ApiConstants.geminiApiKey}'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      _log.i('AI Tahlil: status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text']
                as String?;
        _log.i('AI Tahlil natija: $text');
        return text?.trim();
      } else if (response.statusCode == 429) {
        _log.e('AI Tahlil: kvota tugagan (429)');
        return '⚠️ Server band. Bir oz kutib qayta urinib ko\'ring.';
      } else {
        _log.e('AI Tahlil xatolik: ${response.body}');
        return 'Tahlil amalga oshmadi. Qayta urinib ko\'ring.';
      }
    } catch (e, st) {
      _log.e('AI Tahlil exception', error: e, stackTrace: st);
      return null;
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
