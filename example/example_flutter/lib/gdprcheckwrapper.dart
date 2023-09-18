import 'package:example_flutter/aftergdprcheck.dart';
import 'package:example_flutter/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprpage.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';
import 'package:gdpr_ads/gdpr/gdprupdatepage.dart';

/// This class is a convenience wrapper to make [GdprPage] reusable
/// with the same configuration.
///
/// ### Regular Constent Form and Update Consent Form
///
/// If [showUpdateConsentForm] is false an initial consent form will be shown.
/// If [showUpdateConsentForm] is `true` an update consent form will be shown.
///
/// The initial consent form will check if a consent is necessary first and
/// simpy return without showing a consent form if not. This form is meant to
/// get the initial consent of a user.
///
/// The update consent form will ALLWAYS show its consent form. This form is meant to
/// change a user's consent.
///
/// [resetConfirmationForm] allows for easy testing, it works only with the
/// initial consent form.
class GdprCheckWrapper extends StatelessWidget {
  final bool resetConfirmationForm;
  final bool showUpdateConsentForm;
  const GdprCheckWrapper(
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

  @override
  Widget build(BuildContext context) {
    return showUpdateConsentForm == false
        ?
        // ---------------------------------------------------------------
        // SHOWS AN INITIAL CONSENT FORM
        //
        // IT WILL ONLY SHOW IF NO CONSENT HAS BEEN GIVEN PRIOR
        // ---------------------------------------------------------------
        GdprPage(
            () async => _initAdmob(),
            () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AfterGdprPage()),
              );
            },
            debugTestIdentifiers: Config.testDeviceIds,
            showDebugUI: kDebugMode,
            debugResetConsentForm: resetConfirmationForm,
            loadingWidget: const Center(child: CircularProgressIndicator()),
            debugGeography: GdprDebugGeography.disabled,
          )
        :
        // ---------------------------------------------------------------
        // SHOWS AN UPDATE CONSENT FORM
        //
        // IT WILL ALLWAYS SHOW
        // ---------------------------------------------------------------
        GdprUpdatePage(
            () async => _initAdmob(),
            () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const AfterGdprPage()));
            },
            debugTestIdentifiers: Config.testDeviceIds,
            showDebugUI: kDebugMode,
            loadingWidget: const Center(child: CircularProgressIndicator()),
          );
  }
}
