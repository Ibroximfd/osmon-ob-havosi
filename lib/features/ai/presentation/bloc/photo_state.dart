part of 'photo_bloc.dart';

enum PhotoAction { analyse, restyle, save }

final class PhotoState extends Equatable {
  const PhotoState({
    required this.isConfigured,
    this.original,
    this.mimeType = 'image/jpeg',
    this.edited,
    this.description,
    this.busyWith,
    this.failure,
    this.savedNotice = 0,
  });

  final bool isConfigured;
  final Uint8List? original;
  final String mimeType;
  final Uint8List? edited;
  final String? description;

  /// The action in flight, if any.
  final PhotoAction? busyWith;
  final DataFailure? failure;

  /// Increments after each successful save, for a one-shot snackbar.
  final int savedNotice;

  bool get hasPhoto => original != null;

  PhotoState _copy({
    Uint8List? edited,
    String? description,
    PhotoAction? busyWith,
    DataFailure? failure,
    int? savedNotice,
  }) => PhotoState(
    isConfigured: isConfigured,
    original: original,
    mimeType: mimeType,
    edited: edited ?? this.edited,
    description: description ?? this.description,
    busyWith: busyWith,
    failure: failure,
    savedNotice: savedNotice ?? this.savedNotice,
  );

  PhotoState busy(PhotoAction action) => _copy(busyWith: action);

  PhotoState failed(DataFailure failure) => _copy(failure: failure);

  PhotoState withDescription(String text) => _copy(description: text);

  PhotoState withEdited(Uint8List bytes) => _copy(edited: bytes);

  PhotoState saved() => _copy(savedNotice: savedNotice + 1);

  @override
  List<Object?> get props => <Object?>[
    isConfigured,
    original?.length,
    mimeType,
    edited?.length,
    description,
    busyWith,
    failure,
    savedNotice,
  ];
}
