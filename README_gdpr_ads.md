# The GDPR page and service

The GDPR page uses the GDPR service. 

Make the `GdprPage` the initial screen / home screen of the app and it will display or not display GDPR dialogs as necessary. The page offers debug configuration options like resetting the GDPR consent.

Use the `GdprUpdatePage` to show an update dialog. It will always display the dialog.

Alternatively, use the `GdprService` for a custom solution.

## Initial GDPR consent

```dart
Scaffold(body:
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
        MaterialPageRoute(
            builder: (context) => const AfterGdprPage())
      );
    },
    debugTestIdentifiers: Config.testDeviceIds,
    showDebugUI: kDebugMode,
    loadingWidget: const Center(
        child: CircularProgressIndicator()),
  ),
);
```

## Update GDPR consent

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
        MaterialPageRoute(
            builder: (context) => const AfterGdprPage())
      );
    },
    debugTestIdentifiers: Config.testDeviceIds,
    showDebugUI: kDebugMode,
    loadingWidget: const Center(
        child: CircularProgressIndicator()),
  ),
);
```

# The Ad service

The `AdService` gets initialized and is then shows Ads on request. It attempts to prefetch Ads in the background. Admob does not always return Ads, based on its internal bidding system or connection timeouts.

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
// Will render the Banner directly

Scaffold(
    body:
        AdBanner(String? adUnitId),
);
```

```dart
// Attempts to show an Ad.
// Returns status information about the result.

final ResponseInterstitial result 
  = await AdService().showInterstitial(String? adUnitId);

// Attempts to show a confirmation dialog and then the rewarded Ad.
// Returns status information about the result.

final ResponseInterstitialRewarded result 
  = await AdService().showInterstitialRewarded(context, String? adUnitId);

// Will return the banner and status information.
// No real need to use this, use [AdBanner] instead.

final ResponseBanner result 
  = await AdService().showBanner(String? adUnitId);
```