import 'dart:async';
import 'dart:developer';

import 'package:async_preferences/async_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Allows testing of the `GdprHelper` class for Eea region.
enum GdprDebugGeography { insideEea, outsideEea, disabled }

/// User consent status
enum GdprConsentStatus { notRequired, obtained, required, unknown }

/// In error case, errorCode and errorMessage are set.
///
/// In no error case, the consent status is given.
class GdprResult {
  int? errorCode;
  String? errorMessage;
  GdprConsentStatus? status;

  GdprResult.error(FormError? error) {
    if (error != null) {
      errorCode = error.errorCode;
      errorMessage = error.message;
    }
  }

  GdprResult.status(GdprConsentStatus stat) {
    status = stat;
  }

  bool isError() => errorCode != null;
  bool isSuccess() => errorCode == null;
}

/// Shows the GDPR user consent form if necessary.
///
/// Also allows for updating or reseting it.
class GdprService {
  /// Shows or shows not a consent form.
  /// Returns FormError of consent could not get loaded via the internet
  /// or was not given by user.
  static Future<GdprResult> requestConsentForm(
      {GdprDebugGeography debugGeography = GdprDebugGeography.disabled,
      List<String>? testIdentifiers}) async {
    final completer = Completer<GdprResult>();

    DebugGeography debugArea = DebugGeography.debugGeographyDisabled;

    if (debugGeography != GdprDebugGeography.disabled) {
      debugArea = debugGeography == GdprDebugGeography.insideEea
          ? DebugGeography.debugGeographyEea
          : DebugGeography.debugGeographyNotEea;
    }

    final params = ConsentRequestParameters(
        consentDebugSettings: ConsentDebugSettings(
            debugGeography: debugArea, testIdentifiers: testIdentifiers));

    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        final GdprResult result = await _loadConsentForm();
        completer.complete(result);
      } else {
        final formError = FormError(
            errorCode: 0,
            message: 'Consent Form is not available at the moment');
        completer.complete(GdprResult.error(formError));
      }
    }, (FormError formError) {
      _logFormError(formError);
      completer.complete(GdprResult.error(formError));
    });

    return completer.future;
  }

  /// Allows user to update GDPR consent.
  static Future<GdprResult> updateConsentForm() async {
    final completer = Completer<GdprResult>();

    ConsentInformation.instance
        .requestConsentInfoUpdate(ConsentRequestParameters(), () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        ConsentForm.loadConsentForm((consentForm) {
          consentForm.show((formError) async {
            if (formError != null) {
              _logFormError(formError);
              completer.complete(GdprResult.error(formError));
            } else {
              completer.complete(GdprResult.status(await getConsentStatus()));
            }
          });
        }, (formError) {
          _logFormError(formError);
          completer.complete(GdprResult.error(formError));
        });
      } else {
        final formError = FormError(
            errorCode: 0,
            message: 'Consent Form is not available at the moment');
        _logFormError(formError);
        completer.complete(GdprResult.error(formError));
      }
    }, (formError) {
      _logFormError(formError);
      completer.complete(GdprResult.error(formError));
    });

    return completer.future;
  }

  static Future<GdprResult> _loadConsentForm() async {
    final completer = Completer<GdprResult>();

    ConsentForm.loadConsentForm((consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((FormError? formError) async {
          if (formError != null) {
            _logFormError(formError);
            completer.complete(GdprResult.error(formError));
          } else {
            completer.complete(GdprResult.status(await getConsentStatus()));
          }
        });
      } else {
        completer.complete(GdprResult.status(await getConsentStatus()));
      }
    }, (FormError? formError) {
      _logFormError(formError);
      completer.complete(GdprResult.error(formError));
    });

    return completer.future;
  }

  //// Allows user to reset GDPR consent.
  static Future<void> resetConsentForm() async {
    await ConsentInformation.instance.reset();
    _log('resetConsentForm: done');
  }

  /// Wether the user is under the GDPR.
  ///
  /// Useful for offering options to update GDPR settings.
  ///
  /// This method initializes AsyncPreferences internally,
  /// is is an expensive call.
  static Future<bool> isUserUnderGdpr() async {
    // Initialize AsyncPreferences and checks if the IABTCF_gdprApplies
    // parameter is 1, if it is the user is under the GDPR,
    // any other value could be interpreted as not under the GDPR
    final preferences = AsyncPreferences();
    final userIsUnderGdpr = await preferences.getInt('IABTCF_gdprApplies') == 1;
    _log('userIsUnderGdpr: $userIsUnderGdpr');
    return userIsUnderGdpr;
  }

  /// Returns the current consent status.
  ///
  /// This value is cached by the underlying mechanisms and not exactly reliable.
  static Future<GdprConsentStatus> getConsentStatus() async {
    late GdprConsentStatus ret;
    ConsentStatus status = await ConsentInformation.instance.getConsentStatus();

    switch (status) {
      case ConsentStatus.notRequired:
        ret = GdprConsentStatus.notRequired;
      case ConsentStatus.obtained:
        ret = GdprConsentStatus.obtained;
      case ConsentStatus.required:
        ret = GdprConsentStatus.required;
      case ConsentStatus.unknown:
        ret = GdprConsentStatus.unknown;
    }

    _log('ConsentStatus: $ret');
    return ret;
  }

  static void _logFormError(FormError? formError) {
    if (formError != null) {
      _log(
          'formError: code: ${formError.errorCode} message: ${formError.message}');
    }
  }

  static void _log(String message) {
    log(message, name: 'GdprHelper');
  }
}
