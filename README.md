GDPR service, GDPR intermediate screen, Admob manager for loading and displaying 

## Features

1. Drop-in GDPR widgets suitable for for App startup.
2. Ad loading and displaying.
3. In Flutter Web GDPR and Ads fail gracefully.

## Getting started

This package consists of two components: GDPR and Ads.

Both parts work in conjunction, but can also be used individually, 
more details in the [GDPR and Ads README](README_gdpr_ads.md).

Below is an example combining both parts. 

The steps:

1. Optional: [Update](README_admob.md) AndroidManifest.xml with Admob App ID. 
2. Set `home: GdprCheckWrapper()`.
3. Copy `GdprCheckWrapper.dart` and paste your IDs into it.
4. Display Banner Ads or Intertestial Ads in your code.

## Initialize GDPR and Ads

```dart
void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GdprCheckWrapper(),
    );
  }
}
```

## Update existing GDPR 

```dart
Scaffold(
  body: 
    GdprCheckWrapper(showUpdateConsentForm: true),
);
```

## Create a Helper Widget: GdprCheckWrapper

Copy the helper widget below, it will either show the inital or update GDPR dialog. 

Paste your Admob Ad IDs and Test Device ID into it.

This way your GDPR and Ad related configuration stays in one widget only.

```dart
import 'package:example_flutter/aftergdprcheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprpage.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';
import 'package:gdpr_ads/gdpr/gdprupdatepage.dart';

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
        bannerIds: ['ca-app-pub-3940256099942544/6300978111'],
        interstitialIds: ['ca-app-pub-3940256099942544/1033173712'],
        interRewardIds: ['ca-app-pub-3940256099942544/5354046379'],
        testDeviceIds: [' ... YOUR PHONE DEVICE ID ... ']);
  }

  /// Displays an GDPR initial dialog
  /// It will only display the dialog if not prior GDPR has been collected.
  Widget _gdprPage(BuildContext context) {
    return GdprPage(
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
    );
  }

  /// Displays an GDPR update consent form.
  /// it will always display the dialog.
  Widget _gdprUpdatePage(BuildContext context) {
    return GdprUpdatePage(
      () async => _initAdmob(),
      () {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AfterGdprPage()));
      },
      debugTestIdentifiers: Config.testDeviceIds,
      showDebugUI: kDebugMode,
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showUpdateConsentForm == false
      ? _gdprPage(context)
      : _gdprUpdatePage(context);
  }
}
```

### Show Banner Ads

If no `adUnitId` is given the first available Ad unit will be displayed.

```dart
// In [kDebugMode] some debug info will be shown 
// before the Ad is loaded or in case of error.

Scaffold(
  body:
    AdBanner(String? adUnitId),
);
```

### Show Interstitial Ads and get the result

If no `adUnitId` is given the first available Ad unit will be displayed.

```dart
final ResponseInterstitial result 
  = await AdService().showInterstitial(String? adUnitId);

// Or call:

final ResponseInterstitialRewarded result 
  = await AdService().showInterstitialRewarded(
      context, String? adUnitId);

// The return values look like this:

ResponseInterstitialRewarded {
  StatusInterstitialRewarded status;
  num? rewardAmount;
  String? rewardType;
  int? admobErrorCode;
  String? admobErrorMessage;
}

enum StatusInterstitialRewarded {
  notLoadedOnWeb,
  notLoadedGenerally,
  notLoadedAdIdNotSet,
  displaySuccess,
  displayDeniedByUser,
  displayDeniedProgrammatically,
}
```

## Example

The example folder contains a working example. Set your test device ID before running it, the Ad units can stay as they are. Refrain from hitting the Interstitial buttons too quickly in a row, it will trigger a new background ad fetch at the moment. 

## TODO

- Bounce request for Interstitial and InterstitialRewarded ads when these are still loading.

## Additional information

Google Admob can be painful, Ad slots may not get filled by Admob sometimes, also not sure if VPNs play well with Admob.  

[Issue Tracker](https://github.com/xErik/gdpr_ads/issues).

Admob project configuration

[AndroidManifest.xml and build.gradle](README_admob.md)

