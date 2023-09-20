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
      ).getInitialGdprScreen(),
    );
  }
}
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

final ResponseInterstitialRewarded result 
  = await AdService().showInterstitialRewarded(
      context, String? adUnitId);
```

## Update existing GDPR 

```dart
Scaffold(body: GdprScreenManager.updateGdprScreen() );
```

## Example

The example folder contains a working example. Set your test device ID before running it. The Ad units are Admob demo units. 

## TODO

- Add other ads

## Additional information

Google Admob can be painful, Ad slots may not get filled sometimes, also not sure if VPNs play well with Admob.  

[Issue Tracker](https://github.com/xErik/gdpr_ads/issues).

Admob project configuration

[AndroidManifest.xml and build.gradle](README_admob.md)

