# Ad service

The `AdService` gets initialized and is then shows Ads on request. It attempts to prefetch Ads in the background. Admob does not always return Ads, based on its internal bidding system or connection timeouts.

```dart
AdService().initialize(
  bannerIds: [Config.bannerAdId],
  interstitialIds: [Config.interstitialAdId],
  interRewardIds: [Config.interRewardAdId],
  testDeviceIds: Config.testDeviceIds);
```

# GDPR screen and service

The GDPR screen uses the GDPR service. 

Make the `GdprInitialScreen` the initial screen / home screen of the app and it will display or not display GDPR dialogs as necessary. The screen offers debug configuration options like resetting the GDPR consent.

Use the `GdprUpdateScreen` to show an update dialog. It will always display the dialog.

Alternatively, use the `GdprService` for a custom solution.

## Initial GDPR consent

```dart
Scaffold(body:
  GdprInitialScreen(
    () async {
      AdService().initialize(
          bannerIds: [Config.bannerAdId],
          interstitialIds: [Config.interstitialAdId],
          interRewardIds: [Config.interRewardAdId],
          testDeviceIds: Config.testDeviceIds);
    },
    (BuildContext context) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const AfterGdprScreen())
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
  GdprUpdateScreen(
    () async {
      AdService().initialize(
          bannerIds: [Config.bannerAdId],
          interstitialIds: [Config.interstitialAdId],
          interRewardIds: [Config.interRewardAdId],
          testDeviceIds: Config.testDeviceIds);
    },
    (BuildContext context) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const AfterGdprScreen())
      );
    },
    debugTestIdentifiers: Config.testDeviceIds,
    showDebugUI: kDebugMode,
    loadingWidget: const Center(
        child: CircularProgressIndicator()),
  ),
);
```

