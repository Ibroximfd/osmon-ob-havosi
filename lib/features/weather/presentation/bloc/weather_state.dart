part of 'weather_bloc.dart';

final class WeatherState extends Equatable {
  const WeatherState({
    this.status = LoadStatus.initial,
    this.place,
    this.forecast,
    this.failure,
    this.locationAccess,
    this.isRefreshing = false,
    this.isLocating = false,
    this.pastDay,
    this.aiStory,
  });

  final LoadStatus status;
  final Place? place;

  /// Present when ready, and when offline with a cached copy.
  final Forecast? forecast;
  final DataFailure? failure;

  /// Device-position access as last checked; null until the first check.
  /// Anything but granted shows the "allow location" card.
  final LocationAccess? locationAccess;
  final bool isRefreshing;
  final bool isLocating;
  final PastDay? pastDay;
  final String? aiStory;

  bool get hasContent => forecast != null;

  bool get needsLocationAccess =>
      locationAccess != null && locationAccess != LocationAccess.granted;

  SkyScene get scene {
    final data = forecast;
    return data == null
        ? SkyScene.clearNight
        : skySceneOf(data, data.fetchedAt);
  }

  NowcastOutlook get outlook {
    final data = forecast;
    if (data == null) return const DryOutlook();
    return summarizeNowcast(
      data.nowcast,
      now: data.fetchedAt,
      temperature: data.current.temperature,
    );
  }

  List<LifeIndex> get lifeIndices {
    final data = forecast;
    return data == null ? const <LifeIndex>[] : lifeIndicesFor(data);
  }

  DayStory? get dayStory {
    final data = forecast;
    return data == null ? null : composeDayStory(data);
  }

  PressureTrend? get pressureTrend {
    final data = forecast;
    return data == null ? null : pressureTrendOf(data.pressureHistory);
  }

  /// Today's max minus the same day last year, when both are known.
  double? get lastYearDelta {
    final today = forecast?.today;
    final past = pastDay;
    if (today == null || past == null) return null;
    return today.maxTemperature - past.maxTemperature;
  }

  /// `failure` is assigned, not merged — a successful reload must clear an
  /// old error.
  WeatherState copyWith({
    LoadStatus? status,
    Place? place,
    Forecast? forecast,
    DataFailure? failure,
    LocationAccess? locationAccess,
    bool? isRefreshing,
    bool? isLocating,
    PastDay? pastDay,
    String? aiStory,
  }) => WeatherState(
    status: status ?? this.status,
    place: place ?? this.place,
    forecast: forecast ?? this.forecast,
    failure: failure,
    locationAccess: locationAccess ?? this.locationAccess,
    isRefreshing: isRefreshing ?? false,
    isLocating: isLocating ?? this.isLocating,
    pastDay: pastDay ?? this.pastDay,
    aiStory: aiStory ?? this.aiStory,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    place,
    forecast,
    failure,
    locationAccess,
    isRefreshing,
    isLocating,
    pastDay,
    aiStory,
  ];
}
