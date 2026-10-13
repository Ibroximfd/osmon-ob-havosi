import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/data_failure.dart';
import '../../../location/domain/location_repository.dart';
import '../../../settings/domain/app_settings.dart';
import '../../../settings/domain/notification_permissions.dart';
import '../../../settings/domain/settings_repository.dart';
import '../../domain/language_detection.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required SettingsRepository settings,
    required LocationRepository location,
    required NotificationPermissions notifications,
    required String? deviceLanguageCode,
  }) : _settings = settings,
       _location = location,
       _notifications = notifications,
       super(
         OnboardingState(
           language:
               settings.current.languageCode ??
               detectLanguage(
                 regionCountryCode: location.deviceRegionCode(),
                 deviceLanguageCode: deviceLanguageCode,
               ),
         ),
       ) {
    on<OnboardingStarted>((event, emit) => _applyLanguage(state.language));
    on<OnboardingLanguagePicked>(_onLanguagePicked);
    on<OnboardingStepAdvanced>(
      (event, emit) => emit(state.copyWith(step: state.step.next)),
    );
    on<OnboardingLocationRequested>(_onLocation, transformer: droppable());
    on<OnboardingNotificationsRequested>(
      _onNotifications,
      transformer: droppable(),
    );
    on<OnboardingFinished>(_onFinished, transformer: droppable());
  }

  final SettingsRepository _settings;
  final LocationRepository _location;
  final NotificationPermissions _notifications;

  Future<void> _applyLanguage(String code) =>
      _settings.save(_settings.current.copyWith(languageCode: code));

  Future<void> _onLanguagePicked(
    OnboardingLanguagePicked event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(language: event.code, languageTouched: true));
    await _applyLanguage(event.code);
  }

  Future<void> _onLocation(
    OnboardingLocationRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isRequesting: true));
    final result = await _location.locateDevice(languageCode: state.language);
    await result.fold(
      (failure) async =>
          emit(state.copyWith(isRequesting: false, locationFailure: failure)),
      (place) async {
        await _location.selectPlace(place);
        // GPS is the best language signal; use it unless the user chose.
        final detected = detectLanguage(gpsCountryCode: place.countryCode);
        final switchLanguage =
            !state.languageTouched &&
            place.countryCode != null &&
            detected != state.language;
        if (switchLanguage) await _applyLanguage(detected);
        emit(
          state.copyWith(
            isRequesting: false,
            locationGranted: true,
            language: switchLanguage ? detected : state.language,
          ),
        );
      },
    );
  }

  Future<void> _onNotifications(
    OnboardingNotificationsRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isRequesting: true));
    final granted = await _notifications.request();
    if (granted) {
      // Saying yes here means every kind of notification, all switched on.
      await _settings.save(
        _settings.current.copyWith(
          notifications: NotificationKind.values.toSet(),
        ),
      );
    }
    emit(state.copyWith(isRequesting: false, notificationsGranted: granted));
  }

  Future<void> _onFinished(
    OnboardingFinished event,
    Emitter<OnboardingState> emit,
  ) async {
    await _settings.save(
      _settings.current.copyWith(
        languageCode: state.language,
        onboardingDone: true,
      ),
    );
    emit(state.copyWith(isDone: true));
  }
}
