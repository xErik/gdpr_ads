import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adbanner.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/ads/responseinterstitial.dart';
import 'package:gdpr_ads/ads/responseinterstitialrewarded.dart';
import 'package:gdpr_ads/gdpr/gdprscreenmanager.dart';

class AfterGdprScreen extends StatefulWidget {
  const AfterGdprScreen({Key? key}) : super(key: key);

  @override
  AfterGdprState createState() => AfterGdprState();
}

class AfterGdprState extends State<AfterGdprScreen> {
  ResponseInterstitialRewarded? interRewardedResponse;
  ResponseInterstitial? interResponse;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Screen following GDPR-Screen')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _webWarning(), const SizedBox(height: 32),
            //
            // BANNER
            //
            ListTile(
                title: const Text('Banner', textAlign: TextAlign.center),
                subtitle: AdBanner()),
            //
            // INTERSTITAL
            //
            const SizedBox(height: 32),
            const Divider(thickness: 2, color: Colors.black),
            ListTile(
              title: const Text('Interstitial Ad', textAlign: TextAlign.center),
              subtitle: Column(
                children: [
                  TextButton(
                      onPressed: () => _showInterAd(),
                      child: const Text('Open Interstitial Ad')),
                  Text(_prettyInterStatus()),
                ],
              ),
            ),
            //
            // INTERSTITAL REWARDED
            //
            const SizedBox(height: 32),
            const Divider(thickness: 2, color: Colors.black),
            ListTile(
              title: const Text('Interstitial RewardedAd',
                  textAlign: TextAlign.center),
              subtitle: Column(
                children: [
                  TextButton(
                      onPressed: () => _showInterRewardedAd(context),
                      child: const Text('Open Interstitial Rewarded Ad')),
                  Text(_prettyInterRewardedStatus()),
                ],
              ),
            ),
            //
            // GDPR CHECK AGAIN
            //
            const SizedBox(height: 32),
            const Divider(thickness: 2, color: Colors.black),
            ListTile(
              title: const Text('GDPR check again\n(returns on web)',
                  textAlign: TextAlign.center),
              subtitle: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            GdprScreenManager.initialGdprScreen(),
                      ),
                    );
                  },
                  child: const Text('GDPR Check again')),
            ),
            //
            // RESET GDPR and then GDPR CHECK AGAIN
            //
            const SizedBox(height: 32),
            const Divider(thickness: 2, color: Colors.black),
            ListTile(
              title: const Text(
                  'Reset GDPR and go to GDPR Check\n(returns on web)',
                  textAlign: TextAlign.center),
              subtitle: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            GdprScreenManager.initialResetGdprScreen(),
                      ),
                    );
                  },
                  child: const Text('Reset GDPR and go to GDPR Check')),
            ),
            //
            // UPDATE GDPR CONSENT FORM
            //
            const SizedBox(height: 32),
            const Divider(thickness: 2, color: Colors.black),
            ListTile(
              title: const Text('GDPR update\n(returns on web)',
                  textAlign: TextAlign.center),
              subtitle: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            GdprScreenManager.updateGdprScreen(),
                      ),
                    );
                  },
                  child: const Text('GDPR update')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webWarning() {
    if (kIsWeb) {
      return const ListTile(
        tileColor: Colors.yellow,
        title:
            Text('Ads are not supportet on web!', textAlign: TextAlign.center),
      );
    }

    return const SizedBox.shrink();
  }

  String _prettyInterStatus() {
    String res = '''Status: (ads disabled or not called)''';

    if (interResponse != null) {
      res = '''
Status: ${interResponse!.status.name}
Error Code: ${interResponse!.prettyError()}
''';
    }

    return res;
  }

  String _prettyInterRewardedStatus() {
    String res = '''
Status: (ads disabled or not called)
Reward amount: (ads disabled or not called)
Reward type: (ads disabled or not called)}''';

    if (interRewardedResponse != null) {
      res = '''
Status: ${interRewardedResponse!.status.name}
Reward amount: ${interRewardedResponse!.rewardAmount}
Reward type: ${interRewardedResponse!.rewardType}
${interRewardedResponse!.prettyError()}''';
    }

    return res;
  }

  Future<void> _showInterRewardedAd(BuildContext context) async {
    setState(() => interRewardedResponse = null);
    final result = await AdService().showInterstitialRewarded(context);
    setState(() => interRewardedResponse = result);
  }

  Future<void> _showInterAd() async {
    setState(() => interResponse = null);
    final result = await AdService().showInterstitial();
    setState(() => interResponse = result);
  }
}
