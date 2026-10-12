part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Applies the detected language right away so the first screen is
/// already in it.
final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

final class OnboardingLanguagePicked extends OnboardingEvent {
  const OnboardingLanguagePicked(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

final class OnboardingStepAdvanced extends OnboardingEvent {
  const OnboardingStepAdvanced();
}

final class OnboardingLocationRequested extends OnboardingEvent {
  const OnboardingLocationRequested();
}

final class OnboardingNotificationsRequested extends OnboardingEvent {
  const OnboardingNotificationsRequested();
}

final class OnboardingFinished extends OnboardingEvent {
  const OnboardingFinished();
}
