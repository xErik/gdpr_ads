import 'package:example_flutter/aftergdprscreen.dart';
import 'package:example_flutter/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprinitialscreen.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';
import 'package:gdpr_ads/gdpr/gdprupdatescreen.dart';

/// This class is a convenience wrapper to make [GdprInitialScreen] and
/// [GdprUpdateScreen] reusable with the same configuration.
///
/// ### Regular Consent Form and Update Consent Form
///
/// If [showUpdateConsentForm] is `false` an initial consent form will be shown.
/// If [showUpdateConsentForm] is `true` an update consent form will be shown.
///
/// The initial consent form will check if a consent is necessary first and
/// simpy return without showing a consent form if not. This form is meant to
/// get the initial consent of a user.
///
/// The update consent form will ALWAYS show its consent form. This form is meant to
/// change a user's consent.
///
/// [resetConfirmationForm] allows for easy testing, it works only with the
/// initial consent form.
class GdprScreenWrapper extends StatelessWidget {
  final bool resetConfirmationForm;
  final bool showUpdateConsentForm;

  const GdprScreenWrapper(
      {this.resetConfirmationForm = false,
      this.showUpdateConsentForm = false,
      Key? key})
      : super(key: key);

  void _initAdmob() {
    AdService().initialize(
        bannerIds: [Config.bannerAdId],
        interstitialIds: [Config.interstitialAdId],
        interRewardIds: [Config.interRewardAdId],
        testDeviceIds: Config.testDeviceIds);
  }

  /// Displays an GDPR initial dialog
  /// It will only display the dialog if not prior GDPR has been collected.
  Widget _gdprScreen(BuildContext context) {
    return GdprInitialScreen(
      () async => _initAdmob(),
      (BuildContext context) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AfterGdprScreen()),
        );
      },
      debugTestIdentifiers: Config.testDeviceIds,
      showDebugUI: kDebugMode,
      debugResetConsentForm: resetConfirmationForm,
      loadingWidget: const Center(child: CircularProgressIndicator()),
      debugGeography: GdprDebugGeography.disabled,
    );
  }

  /// Displays an GDPR update consent form.
  /// it will always display the dialog.
  Widget _gdprUpdateScreen(BuildContext context) {
    return GdprUpdateScreen(
      () async => _initAdmob(),
      (BuildContext context) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AfterGdprScreen()));
      },
      debugTestIdentifiers: Config.testDeviceIds,
      showDebugUI: kDebugMode,
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showUpdateConsentForm == false
        ? _gdprScreen(context)
        : _gdprUpdateScreen(context);
  }
}
