import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps the UMP (User Messaging Platform) consent flow bundled with
/// google_mobile_ads. Ad requests must not be sent until [canRequestAds]
/// is true (either consent was given, or none was required for this user).
class AdConsentManager {
  AdConsentManager._();
  static final AdConsentManager instance = AdConsentManager._();

  /// Requests/updates consent info and shows the consent form when the
  /// user's region requires one (Google's recommended single call). Always
  /// completes so startup can't be blocked by a consent-network failure.
  Future<void> gatherConsent() {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (error != null) {
            debugPrint(
              'AdConsentManager: consent form error: ${error.message}',
            );
          }
        });
        if (!completer.isCompleted) completer.complete();
      },
      (FormError error) {
        debugPrint(
          'AdConsentManager: requestConsentInfoUpdate failed: ${error.message}',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  Future<bool> get canRequestAds async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('AdConsentManager: canRequestAds check failed: $e');
      return false;
    }
  }

  /// UMP requires a way to change consent later wherever it applies; the
  /// settings screen shows its entry point only when this is true.
  Future<bool> get isPrivacyOptionsRequired async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      debugPrint('AdConsentManager: privacy options status failed: $e');
      return false;
    }
  }

  Future<void> showPrivacyOptions() => ConsentForm.showPrivacyOptionsForm((
    FormError? error,
  ) {
    if (error != null) {
      debugPrint('AdConsentManager: privacy options error: ${error.message}');
    }
  });
}
