part of 'field_bloc.dart';

sealed class FieldEvent extends Equatable {
  const FieldEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FieldRequested extends FieldEvent {
  const FieldRequested();
}

final class FieldCropSelected extends FieldEvent {
  const FieldCropSelected(this.crop);

  final Crop crop;

  @override
  List<Object?> get props => <Object?>[crop];
}
