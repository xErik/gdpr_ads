```dart
import 'package:example_flutter/aftergdprcheck.dart';
import 'package:example_flutter/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprpage.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';

/// This class is a simple wrapper to make [GdprPage] reusable
/// with the same configuration.
class GdprCheckWrapper extends StatelessWidget {
  final bool resetConfirmationForm;
  const GdprCheckWrapper({this.resetConfirmationForm = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GdprPage(
      () async {
        AdService().setTestDeviceIds(Config.testDeviceIds);
        await AdService().addBanner([Config.bannerAdId]);
        await AdService().addIntersitialRewarded([Config.interRewardAdId]);
        await AdService().addIntersitial([Config.intersitialAdId]);
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