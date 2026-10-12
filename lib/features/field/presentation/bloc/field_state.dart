part of 'field_bloc.dart';

final class FieldState extends Equatable {
  const FieldState({
    required this.crop,
    this.status = LoadStatus.initial,
    this.place,
    this.conditions,
    this.failure,
  });

  final LoadStatus status;
  final Crop crop;
  final Place? place;
  final FieldConditions? conditions;
  final DataFailure? failure;

  FrostOutlook? get frost {
    final data = conditions;
    return data == null ? null : frostOutlookFor(data, crop);
  }

  IrrigationAdvice? get irrigation {
    final data = conditions;
    return data == null ? null : irrigationAdviceFor(data, crop);
  }

  List<SprayWindow> get sprayWindows {
    final data = conditions;
    return data == null ? const <SprayWindow>[] : sprayWindowsFor(data);
  }

  FieldDay? get wetDay {
    final data = conditions;
    return data == null ? null : wetDayAhead(data);
  }

  double? get growingDegreeDaysTotal {
    final data = conditions;
    return data == null ? null : growingDegreeDays(data, crop);
  }

  FieldState copyWith({Crop? crop}) => FieldState(
    crop: crop ?? this.crop,
    status: status,
    place: place,
    conditions: conditions,
    failure: failure,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    crop,
    place,
    conditions,
    failure,
  ];
}
