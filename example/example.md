# Wrapper-Widget for GdprPage

The widget below is a simple wrapper to make [GdprPage] reusable
with the same configuration.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprpage.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';

class GdprCheckWrapper extends StatelessWidget {
  final bool resetConfirmationForm;

  const GdprCheckWrapper({this.resetConfirmationForm = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GdprPage(
      () async {
        AdService().initialize(
            bannerIds: [Config.bannerAdId],
            interstitialIds: [Config.interstitialAdId],
            interRewardIds: [Config.interRewardAdId],
            testDeviceIds: Config.testDeviceIds);
      },
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
    );
  }
}
```