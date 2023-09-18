GDPR service, GDPR intermediate screen, Ad manager for loading and displaying Google Admob ads

## Features

1. GDPR interceptor widget suitable for App startup.
2. GDPR service.
3. Ad service for loading and displaying ads.
4. In Flutter Web the GDPR step and the Ads are automatically excluded.

## Getting started

**Initialize ...**

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
          // (This will work even if the user has DENIED GDPR,
          // Admob will then not deliver ads.)
          //
          AdService().setTestDeviceIds(Config.testDeviceIds);
          await AdService().addBanner([Config.bannerAdId]);
          await AdService().addInterstitialRewarded([Config.interRewardAdId]);
          await AdService().addInterstitial([Config.interstitialAdId]);
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
        showDebugUI: kDebugMode,
        debugResetConsentForm: resetConfirmationForm,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        debugGeography: GdprDebugGeography.disabled,
      ),
    );
  }
}
```

**... and show ads**

```dart
Scaffold(body:AdBanner())

// Or

final ResponseInterstitial? result 
  = await AdService().showInterstitial();
```

## Usage

The example folder contains a complete example (which will run on the web, too, but show no ads). Add your test device ID before running it. Refrain from hitting the Intertestial buttons to often, Admob will deny too many requests. 

### The GDPR page and service

The GDPR page makes use of the GDPR service. 

Make the GDPR widget the initial screen / home screen of the app and it will display or not display GDPR dialogs as necessary. The widget offers debug configuration options like resetting the GDPR consent.

Alternativly, user the GDPR service for a custom solution.

### The Ads service

The Ads service needs to get initialized once and is then used to display Ads. It attempts to load Ads in the background when needed.

```dart
AdService(testDeviceIds: Config.testDeviceIds);
AdService().initBanner([Config.bannerAdId]);
AdService().initInterstitialRewarded([Config.interRewardAdId]);
AdService().initInterstitial[(Config.interstitialAdId]);
```

Show ads after [AdService] has been initialized:

```dart
// Will render the banner directly
Scaffold(body:AdBanner()),
```

```dart
// Will attempt to show an ad.
// Returns status information about the result.
// If [adunitId] is NULL the first ad is selected.
final ResponseInterstitial? result 
  = await AdService().showInterstitial(String? adUnitId);

// Will attempt to show a dialog and then the rewarded ad.
// Returns status information about the result.
// If [adunitId] is NULL the first ad is selected.
final ResponseInterstitialRewarded? result 
  = await AdService().showInterstitialRewarded(context, String? adUnitId);

// Will return the banner and status information.
// If [adunitId] is NULL the first ad is selected.
final ResponseBanner? result 
  = await AdService().showBanner(String? adUnitId);
```

### The GDPR page combined with the Ads service

**The GDPR page combined with the Ads service** allows for easy management of GDPR and Ads.

The example below domstrates how to request a GDPR check on App startup.

The `GdprPage` may show a GDPR-Confirmation. In case a confirmation has already
been obtained in the past it will forward to the next page.

`GdprPage` requires two Function-parameters.The first function will be called 
after the user hads been presented with a GDPR confirmation dialog; or if 
a confirmation had been obtained in the past.

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
          // GDPR dialog had been show and the user had
          // interacted with it.
          // 
          // It will not be called in case of technical 
          // errors etc.
          //
          // (This does work even if the user has declined GDPR,
          // as Admob will then not deliver ads.)
          //
          AdService().setTestDeviceIds(Config.testDeviceIds);
          await AdService().addBanner([Config.bannerAdId]);
          await AdService().addInterstitialRewarded([Config.interRewardAdId]);
          await AdService().addInterstitial([Config.interstitialAdId]);
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
        showDebugUI: kDebugMode,
        debugResetConsentForm: resetConfirmationForm,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        debugGeography: GdprDebugGeography.disabled,
      ),
    );
  }
}
```

### TODO

Rate limit Interstitial and InterstitialRewarded ads, at the moment each invocation
will trigger a new fetch over the internet. The loading status should be internally 
recognized and a appropirate repsonse should be returned. 

## Additional information

Ads are quirky and Google Admob can be painful, Ad slots may not get filled by Admob sometimes, some VPNs do get get served with Ads.  

Please open issues here:

https://github.com/xErik/gdpr_ads/issues

## Update AndroidManifest.xml and build.gradle

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