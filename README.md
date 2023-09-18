GDPR service, GDPR intermediate screen, Admob manager for loading and displaying 

## Features

1. GDPR interceptor widget suitable for App startup.
2. GDPR service.
3. Ad service for loading and displaying Ads.
4. In Flutter Web the GDPR step and the Ads are automatically excluded.

## Getting started

**Initialize consent form and ads as initial home page**

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
      home: GdprPage(
        () async {
          //
          // This will function will be called if a 
          // GDPR dialog had been show.
          // 
          // It will not be called in case of technical 
          // errors etc.
          //
          // This works even if the user has DENIED GDPR:
          // Admob will then not deliver ads and return error 3/no-fill.
          //
          AdService().initialize(
            bannerIds: [Config.bannerAdId],
            interstitialIds: [Config.interstitialAdId],
            interRewardIds: [Config.interRewardAdId],
            testDeviceIds: Config.testDeviceIds);
        },
        () {
          //
          // This will route to the next page after the GDPR dialog 
          // has been displayed.
          //
          // Also in case of technical errors etc.
          //
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AfterGdprPage()),
          );
        },
        //
        // Optional
        //
        debugTestIdentifiers: Config.testDeviceIds,
        // shows a debug UI instead of the regular one
        showDebugUI: kDebugMode,
        // will reset consent form before showing it
        debugResetConsentForm: resetConfirmationForm,
        // Will be placed in a Scaffold 
        loadingWidget: const Center(child: CircularProgressIndicator()),
        // Set the geography for testing
        debugGeography: GdprDebugGeography.disabled,
      ),
    );
  }
}
```

**Show ads**

```dart
// In [kDebugMode] some debug info will be shown 
// before the Ad is loaded or in case of error.

Scaffold(body:AdBanner(String? adUnitId))

// Or 

final ResponseInterstitial result 
  = await AdService().showInterstitial(String? adUnitId);

// Or 

final ResponseInterstitialRewarded result 
  = await AdService().showInterstitialRewarded(context, String? adUnitId);

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

If no `adUnitId` is given the first available ad unit will be shown.

**Update a consent**

```dart
Scaffold(body:
  GdprUpdatePage(
    () async {
      AdService().initialize(
          bannerIds: [Config.bannerAdId],
          interstitialIds: [Config.interstitialAdId],
          interRewardIds: [Config.interRewardAdId],
          testDeviceIds: Config.testDeviceIds);
    },
    () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AfterGdprPage())
      );
    },
    debugTestIdentifiers: Config.testDeviceIds,
    showDebugUI: kDebugMode,
    loadingWidget: const Center(child: CircularProgressIndicator()),
  ),
);
```

## Usage

The example folder contains a complete example (it will run on the web, too, but show no ads). Set your test device ID before running it, the Ad units can stay as they are. Refrain from hitting the Interstitial buttons too quickly in a row, it will trigger a new fetch at the moment. 

### The GDPR page and service

The GDPR page uses the GDPR service. 

Make the GDPR page the initial screen / home screen of the app and it will display or not display GDPR dialogs as necessary. The page offers debug configuration options like resetting the GDPR consent.

Use the GDPR update page to show an update dialog. It will always display the dialog.

Alternatively, use the GDPR service for a custom solution.

### The Ads service

The Ads service gets initialized and is then shows Ads on request. It attempts to prefetch Ads in the background. Admob does not always return Ads, based on its internal bidding system or connection timeouts.

```dart
AdService().initialize(
  bannerIds: [Config.bannerAdId],
  interstitialIds: [Config.interstitialAdId],
  interRewardIds: [Config.interRewardAdId],
  testDeviceIds: Config.testDeviceIds);
```

Show Ads after [AdService] has been initialized. The optional parameter [adUnitId] 
allows for selecting a specific Admob-Ad-ID, if not given the first found Ad will 
be shown (or returned).  

```dart
// Will render the banner directly
Scaffold(body:AdBanner(String? adUnitId)),
```

```dart
// Attempts to show an Ad.
// Returns status information about the result.
//
final ResponseInterstitial result 
  = await AdService().showInterstitial(String? adUnitId);

// Attempts to show a confirmation dialog and then the rewarded Ad.
// Returns status information about the result.
//
final ResponseInterstitialRewarded result 
  = await AdService().showInterstitialRewarded(context, String? adUnitId);

// Will return the banner and status information.
// No real need to use this, use [AdBanner] instead.
//
final ResponseBanner result 
  = await AdService().showBanner(String? adUnitId);
```

### The GDPR page combined with the Ads service

**The GDPR page combined with the Ads service** allows for easy management of GDPR and Ads.

The code below domstrates how to request a GDPR check on App startup.

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

      // To show the update consent form, 
      // not the initial one:
      // 
      // GdprCheckWrapper(
      //   showUpdateConsentForm: true),
    );
  }
}
```

```dart
import 'package:example_flutter/aftergdprcheck.dart';
import 'package:example_flutter/config.dart';
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
          )
        :
        // ---------------------------------------------------------------
        // SHOWS AN UPDATE CONSENT FORM
        //
        // IT WILL ALLWAYS SHOW
        // ---------------------------------------------------------------
        GdprUpdatePage(
            () async {
              AdService().initialize(
                  bannerIds: [Config.bannerAdId],
                  interstitialIds: [Config.interstitialAdId],
                  interRewardIds: [Config.interRewardAdId],
                  testDeviceIds: Config.testDeviceIds);
            },
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
```

## TODO

- Bounce request for Interstitial and InterstitialRewarded ads when these are still loading.

## Additional information

Google Admob can be painful, Ad slots may not get filled by Admob sometimes, also not sure if VPNs play well with Admob.  

Please open issues here:

https://github.com/xErik/gdpr_ads/issues

## Enable Ads in Android Project

Update AndroidManifest.xml and build.gradle

1. Admob requires updating `AndroidManifest.xml` with an Addmob App-Id.
2. In case of DEX compile errors, update `build.gradle`.

### AndroidManifest.xml

Add the Admob-App-ID to `android/app/src/AndroidManifest.xml`.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

	<uses-permission android:name="android.permission.INTERNET" />

  <!-- In case of DEX errors -->
	<application android:name="androidx.multidex.MultiDexApplication">	
		
        <meta-data 
            android:name="com.google.android.gms.ads.APPLICATION_ID" 
            android:value=" -- YOUR ADMOB APPLICATION ID HERE -- " /> 

   <!-- ... -->

</manifest>        
```
### build.gradle

In case of DEX compile errors, add these entries to `android/app/build.gradle` and the
MULTIDEX entry to the `AndroidManifest.xml` as given above.

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation "androidx.multidex:multidex:2.0.1"
}
```