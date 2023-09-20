import 'package:example_flutter/aftergdprscreen.dart';
import 'package:example_flutter/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/gdpr/gdprscreenmanager.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';

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
        (BuildContext context) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AfterGdprScreen())),
        bannerIds: [Config.bannerAdId],
        interstitialIds: [Config.interstitialAdId],
        interRewardIds: [Config.interRewardAdId],
        debugTestDeviceIds: Config.testDeviceIds,
        debugShowDebugUI: kDebugMode,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        debugGeography: GdprDebugGeography.disabled,
      ).getInitialGdprScreen(),
    );
  }
}
