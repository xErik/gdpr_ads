GDPR service, GDPR intermediate screen, Admob manager for loading and displaying 

## Features

1. GDPR Manager.
2. Ads loading, displaing and returning the results.
3. GDPR and Ads fail gracefully.

## Getting started

This package consists of two components: GDPR and Ads. Noth may be used [individually](README_gdpr_ads.md). The example below combines both components. 

Steps:

1. Configure `MaterialApp( home: GdprScreenManager() )`.
2. Display Ads.
3. Update or reset GDPR on request. 

## Initialize GDPR and Ads

Add a navigation method that will navigate to the next screen after the GDPR screen. In the exmaple below, replace `AfterGdprScreen()` with your own widget.

Set Ad units and test device IDs. The Ad units below are Admob demo Ad units and are safe to use.

Will show GDPR dialog if user never interacted with it.

Will not show GDPR dialog if user already interacted with it.

```dart
void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GdprScreenManager(
        
        (BuildContext context) => 
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => 
              const AfterGdprScreen())),

        bannerIds: ["ca-app-pub-3940256099942544/6300978111"],
        interstitialIds: ["ca-app-pub-3940256099942544/1033173712"],
        interRewardIds: ["ca-app-pub-3940256099942544/5354046379"],
        
        debugTestDeviceIds: [" ... YOUR TEST DEVICE ID HERE ... "],

        // Force or unforce GDPR dialog for testing
        debugGeography: GdprDebugGeography.insideEea,
      ).getInitialGdprScreen(),
    );
  }
}
```

### Re-Visit GDPR

Will show GDPR dialog if user never interacted with it.

Will not show GDPR dialog if user already interacted with it.

`GdprService.isUserUnderGdpr()` returns if GDPR applies to users' location in general. Useful for showing a condictional Update-Button.

```dart
if(GdprService.isUserUnderGdpr()) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) =>
          GdprScreenManager.initialGdprScreen(),
    ),
  );
}
```

### Update existing GDPR 

Will always show GDPR dialog, regardless of whether user already interacted with it or not.

```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) =>
        GdprScreenManager.updateGdprScreen(),
  )
)
```

### Reset and then re-visit GDPR 

Will reset GDPR dialog and then re-visit GDPR dialog, regardless of whether user already interacted with it or not.

Will always show GDPR dialog, regardless of whether user already interacted with it or not.

```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) =>
        GdprScreenManager.initialResetGdprScreen(),
  ),
)
```

## Show Ads

If no `adUnitId` is given the first available Ad unit will be displayed. 

In `kDebugMode` the `AdBanner`` will display additonal info.

```dart
Scaffold(body: AdBanner(String? adUnitId) );
```

The returned responses have a status-enum detailing
the results.

```dart
final ResponseInterstitial result 
  = await AdService().showInterstitial(String? adUnitId);
```

A Rewarded Interstitial requires a dialog with a timer. 

The appearance of this dialog has to match your app's design.

For convenience, copy the class `RewardedInterstitialDialog` into your project and skin the AlertDialog inside as needed, find the source [here](README_rewardedinterstitialdialog.md). 

Then, call `AdService().showInterstitialRewarded()` with your dialog as a parameter as given below.

```dart
// Both `adUnitId`s referenced below need to be the same.

final String? adUnitId = null;

// Or

final String? adUnitId = '... Ad unit ID ... ';

final ResponseInterstitialRewarded result 
  = await AdService().showInterstitialRewarded(
      context, 
      const RewardedInterstitialDialog(
        adUnitId:adUnitId, countdownSeconds:5,
      ),
      adUnitId:adUnitId,
    );
```

## Example

The example folder contains a working example. Set your test device ID before running it. The Ad units are Admob demo units and safe to use. 

## TODO

- Add other ads

## Additional information

Google Admob can be painful, GDPR may time out, Ad slots may not get filled sometimes, also not sure if VPNs play well with Admob.  

[Issue Tracker](https://github.com/xErik/gdpr_ads/issues).

Admob project configuration

[AndroidManifest.xml and build.gradle](README_admob.md)

