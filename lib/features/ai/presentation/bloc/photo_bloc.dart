import 'dart:typed_data';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/data_failure.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/ai_repository.dart';
import '../../domain/gallery_saver.dart';

part 'photo_event.dart';
part 'photo_state.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc(this._ai, this._gallery, this._settings)
    : super(PhotoState(isConfigured: _ai.isConfigured)) {
    on<PhotoPicked>(
      (event, emit) => emit(
        PhotoState(
          isConfigured: state.isConfigured,
          original: event.bytes,
          mimeType: event.mimeType,
        ),
      ),
    );
    on<PhotoAnalysisRequested>(_onAnalysis, transformer: droppable());
    on<PhotoRestyleRequested>(_onRestyle, transformer: droppable());
    on<PhotoSaveRequested>(_onSave, transformer: droppable());
    on<PhotoCleared>(
      (event, emit) => emit(PhotoState(isConfigured: state.isConfigured)),
    );
  }

  final AiRepository _ai;
  final GallerySaver _gallery;
  final SettingsRepository _settings;

  Future<void> _onAnalysis(
    PhotoAnalysisRequested event,
    Emitter<PhotoState> emit,
  ) async {
    final original = state.original;
    if (original == null) return;
    emit(state.busy(PhotoAction.analyse));
    final result = await _ai.describePhoto(
      original,
      mimeType: state.mimeType,
      languageCode: _settings.current.languageCode ?? 'uz',
    );
    result.fold(
      (failure) => emit(state.failed(failure)),
      (text) => emit(state.withDescription(text)),
    );
  }

  Future<void> _onRestyle(
    PhotoRestyleRequested event,
    Emitter<PhotoState> emit,
  ) async {
    final original = state.original;
    if (original == null) return;
    emit(state.busy(PhotoAction.restyle));
    final result = await _ai.restylePhoto(
      original,
      mimeType: state.mimeType,
      instruction: event.style.instruction,
    );
    result.fold(
      (failure) => emit(state.failed(failure)),
      (bytes) => emit(state.withEdited(bytes)),
    );
  }

  Future<void> _onSave(
    PhotoSaveRequested event,
    Emitter<PhotoState> emit,
  ) async {
    final image = state.edited ?? state.original;
    if (image == null) return;
    emit(state.busy(PhotoAction.save));
    final result = await _gallery.save(image);
    result.fold(
      (failure) => emit(state.failed(failure)),
      (_) => emit(state.saved()),
    );
  }
}
