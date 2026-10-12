import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/data_failure.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/guard.dart';
import '../../../core/network/json_reader.dart';
import '../../weather/domain/entities/forecast.dart';
import '../domain/ai_repository.dart';
import '../domain/chat_turn.dart';

final class GeminiAiRepository implements AiRepository {
  const GeminiAiRepository(this._http, this._prefs);

  final Dio _http;
  final SharedPreferences _prefs;

  static const Duration _storyTtl = Duration(minutes: 30);
  static const String _storyKey = 'v2.ai_story';
  static const int _historyTurns = 10;

  static const Map<String, String> _languageNames = <String, String>{
    'uz': 'Uzbek in Latin script',
    'ru': 'Russian',
    'en': 'English',
    'kk': 'Kazakh in Cyrillic script',
    'ky': 'Kyrgyz in Cyrillic script',
    'tg': 'Tajik in Cyrillic script',
  };

  @override
  bool get isConfigured => ApiEndpoints.isGeminiConfigured;

  String _language(String code) => _languageNames[code] ?? 'Uzbek';

  @override
  Future<Either<DataFailure, String>> writeDayStory(
    Forecast forecast, {
    required String languageCode,
  }) async {
    if (!isConfigured) {
      return const Left<DataFailure, String>(UnconfiguredFailure());
    }
    final cacheId =
        '${forecast.place.key}|${forecast.fetchedAt.hour}|$languageCode';
    final cached = _readStory(cacheId);
    if (cached != null) return Right<DataFailure, String>(cached);

    final result = await _generateText(<Map<String, Object>>[
      _userContent(_storyPrompt(forecast, languageCode)),
    ], temperature: 0.7);
    return result.map((text) {
      _writeStory(cacheId, text);
      return text;
    });
  }

  @override
  Future<Either<DataFailure, String>> reply(
    List<ChatTurn> conversation, {
    required String languageCode,
    Forecast? forecast,
  }) async {
    if (!isConfigured) {
      return const Left<DataFailure, String>(UnconfiguredFailure());
    }
    final recent = conversation.length > _historyTurns
        ? conversation.sublist(conversation.length - _historyTurns)
        : conversation;
    final instruction =
        'You are the assistant inside Osmon, a weather app. Help only with '
        'weather and what to do because of it. Answer in '
        '${_language(languageCode)}. Be concrete and short (at most 6 '
        'sentences). Plain text, no markdown.'
        '${forecast == null ? '' : '\n\nCurrent data: ${_describe(forecast)}'}';
    return _generateText(<Map<String, Object>>[
      _userContent(instruction),
      _modelContent('OK.'),
      for (final turn in recent)
        turn.fromUser ? _userContent(turn.text) : _modelContent(turn.text),
    ], temperature: 0.6);
  }

  @override
  Future<Either<DataFailure, String>> describePhoto(
    Uint8List bytes, {
    required String mimeType,
    required String languageCode,
  }) async {
    if (!isConfigured) {
      return const Left<DataFailure, String>(UnconfiguredFailure());
    }
    final prompt =
        'Look at this photo as a meteorologist. In ${_language(languageCode)}, '
        'in at most 4 short sentences: what weather it shows, the likely '
        'temperature range, what the clouds or light suggest for the next '
        'hours, and one practical tip. Plain text, no markdown.';
    return _generateText(<Map<String, Object>>[
      <String, Object>{
        'role': 'user',
        'parts': <Object>[
          <String, String>{'text': prompt},
          <String, Object>{
            'inline_data': <String, String>{
              'mime_type': mimeType,
              'data': base64Encode(bytes),
            },
          },
        ],
      },
    ], temperature: 0.5);
  }

  @override
  Future<Either<DataFailure, Uint8List>> restylePhoto(
    Uint8List bytes, {
    required String mimeType,
    required String instruction,
  }) async {
    if (!isConfigured) {
      return const Left<DataFailure, Uint8List>(UnconfiguredFailure());
    }
    return guard(() async {
      final json = await _post(ApiEndpoints.geminiImageModel, <String, Object>{
        'contents': <Object>[
          <String, Object>{
            'role': 'user',
            'parts': <Object>[
              <String, String>{'text': instruction},
              <String, Object>{
                'inline_data': <String, String>{
                  'mime_type': mimeType,
                  'data': base64Encode(bytes),
                },
              },
            ],
          },
        ],
        'generationConfig': <String, Object>{
          'responseModalities': <String>['TEXT', 'IMAGE'],
        },
      });
      for (final part in _parts(json)) {
        final inline =
            part.objectOrNull('inlineData') ?? part.objectOrNull('inline_data');
        if (inline != null) return base64Decode(inline.text('data'));
      }
      throw const FormatException('no image in response');
    });
  }

  Future<Either<DataFailure, String>> _generateText(
    List<Map<String, Object>> contents, {
    required double temperature,
  }) => guard(() async {
    final json = await _post(ApiEndpoints.geminiTextModel, <String, Object>{
      'contents': contents,
      'generationConfig': <String, Object>{
        'temperature': temperature,
        'maxOutputTokens': 1024,
      },
    });
    final text = _parts(
      json,
    ).map((part) => part.textOrNull('text')).whereType<String>().join().trim();
    if (text.isEmpty) throw const FormatException('empty text');
    return text;
  });

  Future<Map<String, dynamic>> _post(
    String model,
    Map<String, Object> body,
  ) async {
    final response = await _http.post<Map<String, dynamic>>(
      '${ApiEndpoints.gemini}/$model:generateContent',
      queryParameters: <String, String>{'key': ApiEndpoints.geminiApiKey},
      data: body,
      options: Options(receiveTimeout: const Duration(seconds: 60)),
    );
    return response.data ?? (throw const FormatException('empty body'));
  }

  static List<Map<String, dynamic>> _parts(Map<String, dynamic> json) {
    final candidates = json.list('candidates');
    if (candidates.isEmpty) return const <Map<String, dynamic>>[];
    final first = candidates.first;
    if (first is! Map<String, dynamic>) return const <Map<String, dynamic>>[];
    final content = first.objectOrNull('content');
    return (content?.listOrNull('parts') ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Map<String, Object> _userContent(String text) => <String, Object>{
    'role': 'user',
    'parts': <Object>[
      <String, String>{'text': text},
    ],
  };

  static Map<String, Object> _modelContent(String text) => <String, Object>{
    'role': 'model',
    'parts': <Object>[
      <String, String>{'text': text},
    ],
  };

  String _storyPrompt(Forecast forecast, String languageCode) =>
      'Weather for today: ${_describe(forecast)}\n\n'
      'Write exactly three short sentences in ${_language(languageCode)} for '
      'someone planning their day: 1) what to wear, 2) what to watch out '
      'for, 3) the best hour to be outside and why. No greeting, no '
      'introduction, no markdown, no emoji. Be specific to these numbers.';

  static String _describe(Forecast f) {
    final today = f.today;
    final wettest = f.hourly
        .take(18)
        .fold<HourlyWeather?>(
          null,
          (best, h) =>
              best == null ||
                  h.precipitationProbability > best.precipitationProbability
              ? h
              : best,
        );
    return <String>[
      'place ${f.place.name}',
      'local time ${f.fetchedAt.hour}:${f.fetchedAt.minute.toString().padLeft(2, '0')}',
      'now ${f.current.temperature.round()}°C, feels ${f.current.apparentTemperature.round()}°C',
      'condition ${f.current.condition.name}',
      if (today != null)
        'today min ${today.minTemperature.round()}°C max ${today.maxTemperature.round()}°C, UV max ${today.uvIndexMax.round()}',
      'humidity ${f.current.humidity.round()}%',
      'wind ${f.current.windSpeed.round()} km/h, gusts ${f.current.windGusts.round()} km/h',
      if (wettest != null)
        'highest rain chance ${wettest.precipitationProbability.round()}% at ${wettest.time.hour}:00',
      if (f.air?.usAqi != null) 'US AQI ${f.air!.usAqi!.round()}',
    ].join('; ');
  }

  String? _readStory(String id) {
    final raw = _prefs.getString(_storyKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['id'] != id) return null;
    final savedAt = decoded['at'];
    if (savedAt is! int) return null;
    final age = DateTime.now().millisecondsSinceEpoch - savedAt;
    if (age > _storyTtl.inMilliseconds) return null;
    return decoded['text'] as String?;
  }

  void _writeStory(String id, String text) => _prefs.setString(
    _storyKey,
    jsonEncode(<String, Object>{
      'id': id,
      'text': text,
      'at': DateTime.now().millisecondsSinceEpoch,
    }),
  );
}
