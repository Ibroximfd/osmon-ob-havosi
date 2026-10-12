part of 'onboarding_bloc.dart';

enum OnboardingStep {
  language,
  features,
  permissions;

  OnboardingStep get next => switch (this) {
    OnboardingStep.language => OnboardingStep.features,
    OnboardingStep.features => OnboardingStep.permissions,
    OnboardingStep.permissions => OnboardingStep.permissions,
  };
}

final class OnboardingState extends Equatable {
  const OnboardingState({
    required this.language,
    this.step = OnboardingStep.language,
    this.languageTouched = false,
    this.isRequesting = false,
    this.locationGranted = false,
    this.notificationsGranted = false,
    this.locationFailure,
    this.isDone = false,
  });

  final OnboardingStep step;
  final String language;

  /// True once the user picked a language by hand; detection then stops.
  final bool languageTouched;
  final bool isRequesting;
  final bool locationGranted;
  final bool notificationsGranted;
  final DataFailure? locationFailure;
  final bool isDone;

  OnboardingState copyWith({
    OnboardingStep? step,
    String? language,
    bool? languageTouched,
    bool? isRequesting,
    bool? locationGranted,
    bool? notificationsGranted,
    DataFailure? locationFailure,
    bool? isDone,
  }) => OnboardingState(
    step: step ?? this.step,
    language: language ?? this.language,
    languageTouched: languageTouched ?? this.languageTouched,
    isRequesting: isRequesting ?? this.isRequesting,
    locationGranted: locationGranted ?? this.locationGranted,
    notificationsGranted: notificationsGranted ?? this.notificationsGranted,
    locationFailure: locationFailure,
    isDone: isDone ?? this.isDone,
  );

  @override
  List<Object?> get props => <Object?>[
    step,
    language,
    languageTouched,
    isRequesting,
    locationGranted,
    notificationsGranted,
    locationFailure,
    isDone,
  ];
}
