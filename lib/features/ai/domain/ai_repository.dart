import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../core/error/data_failure.dart';
import '../../weather/domain/entities/forecast.dart';
import 'chat_turn.dart';

/// Gemini-backed text and image features. Every method answers in the
/// user's language and fails with [UnconfiguredFailure] when this build has
/// no API key.
abstract interface class AiRepository {
  bool get isConfigured;

  /// A three-sentence plan for the day (cached for 30 minutes per forecast).
  Future<Either<DataFailure, String>> writeDayStory(
    Forecast forecast, {
    required String languageCode,
  });

  Future<Either<DataFailure, String>> reply(
    List<ChatTurn> conversation, {
    required String languageCode,
    Forecast? forecast,
  });

  Future<Either<DataFailure, String>> describePhoto(
    Uint8List bytes, {
    required String mimeType,
    required String languageCode,
  });

  /// Returns the edited image (PNG/JPEG bytes).
  Future<Either<DataFailure, Uint8List>> restylePhoto(
    Uint8List bytes, {
    required String mimeType,
    required String instruction,
  });
}
