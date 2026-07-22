import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps the UMP (User Messaging Platform) consent flow bundled with
/// google_mobile_ads. Ad requests must not be sent until [canRequestAds]
/// is true (either consent was given, or none was required for this user).
class AdConsentManager {
  AdConsentManager._();
  static final AdConsentManager instance = AdConsentManager._();

  /// Requests/updates consent info and shows the consent form if required.
  /// Always completes (never throws) so startup can't be blocked by a
  /// consent-network failure.
  Future<void> gatherConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadAndShowForm(completer);
          } else {
            _complete(completer);
          }
        } catch (e) {
          debugPrint('AdConsentManager: post-update error: $e');
          _complete(completer);
        }
      },
      (FormError error) {
        debugPrint('AdConsentManager: requestConsentInfoUpdate failed: '
            '${error.message}');
        _complete(completer);
      },
    );

    return completer.future;
  }

  Future<void> _loadAndShowForm(Completer<void> completer) async {
    ConsentForm.loadConsentForm(
      (ConsentForm form) async {
        final status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          form.show((FormError? showError) {
            if (showError != null) {
              debugPrint('AdConsentManager: form show error: '
                  '${showError.message}');
            }
            _complete(completer);
          });
        } else {
          _complete(completer);
        }
      },
      (FormError error) {
        debugPrint('AdConsentManager: loadConsentForm failed: '
            '${error.message}');
        _complete(completer);
      },
    );
  }

  void _complete(Completer<void> completer) {
    if (!completer.isCompleted) completer.complete();
  }

  Future<bool> get canRequestAds async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      debugPrint('AdConsentManager: canRequestAds check failed: $e');
      return false;
    }
  }
}
