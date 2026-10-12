part of 'photo_bloc.dart';

/// Weather looks the restyle feature offers. The instruction stays in
/// English because the image model follows English prompts most reliably.
enum PhotoStyle {
  snow(
    'Make this exact photo look like a heavy snowfall day. Keep the scene and composition; add falling snow and snow cover.',
  ),
  rain(
    'Make this exact photo look like a rainy evening: wet reflective surfaces, falling rain, moody grey sky. Keep the composition.',
  ),
  sunset(
    'Relight this exact photo as golden-hour sunset with warm light and long shadows. Keep the composition.',
  ),
  storm(
    'Make this exact photo look like a dramatic thunderstorm with dark clouds and a lightning bolt in the sky. Keep the composition.',
  ),
  clear(
    'Make this exact photo look like a perfectly clear, sunny spring day with a deep blue sky. Keep the composition.',
  );

  const PhotoStyle(this.instruction);

  final String instruction;
}

sealed class PhotoEvent extends Equatable {
  const PhotoEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class PhotoPicked extends PhotoEvent {
  const PhotoPicked(this.bytes, this.mimeType);

  final Uint8List bytes;
  final String mimeType;

  @override
  List<Object?> get props => <Object?>[bytes.length, mimeType];
}

final class PhotoAnalysisRequested extends PhotoEvent {
  const PhotoAnalysisRequested();
}

final class PhotoRestyleRequested extends PhotoEvent {
  const PhotoRestyleRequested(this.style);

  final PhotoStyle style;

  @override
  List<Object?> get props => <Object?>[style];
}

final class PhotoSaveRequested extends PhotoEvent {
  const PhotoSaveRequested();
}

final class PhotoCleared extends PhotoEvent {
  const PhotoCleared();
}
