import 'package:example_flutter/gdprcheckwrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adbanner.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/ads/responseintersitial.dart';
import 'package:gdpr_ads/ads/responseintersitialrewarded.dart';

class AfterGdprPage extends StatefulWidget {
  const AfterGdprPage({Key? key}) : super(key: key);

  @override
  AfterGdprState createState() => AfterGdprState();
}

class AfterGdprState extends State<AfterGdprPage> {
  ResponseInterstitialRewarded? interRewardedResponse;
  ResponseInterstitial? interResponse;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Page following GDPR-Page')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _webWarning(), const SizedBox(height: 32),
            //
            // BANNER
            //
            const ListTile(
                title: Text('Banner', textAlign: TextAlign.center),
                subtitle: AdBanner()),
            //
            // INTERSITIAL
            //
            const SizedBox(height: 32),
            ListTile(
              title: const Text('Intersitial Ad', textAlign: TextAlign.center),
              subtitle: Column(
                children: [
                  TextButton(
                      onPressed: () => _showInterAd(),
                      child: const Text('Open Intersitial Ad')),
                  Text(_prettyInterStatus()),
                ],
              ),
            ),
            //
            // INTERSITIAL REWARDED
            //
            const SizedBox(height: 32),
            ListTile(
              title: const Text('Intersitial RewardedAd',
                  textAlign: TextAlign.center),
              subtitle: Column(
                children: [
                  TextButton(
                      onPressed: () => _showInterRewardedAd(context),
                      child: const Text('Open Intersitial Rewarded Ad')),
                  Text(_prettyInterRewardedStatus()),
                ],
              ),
            ),
            //
            // GDPR CHECK AGAIN
            //
            const SizedBox(height: 32),
            ListTile(
              title: const Text('GDPR check again\n(returns on web)',
                  textAlign: TextAlign.center),
              subtitle: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GdprCheckWrapper(),
                      ),
                    );
                  },
                  child: const Text('GDPR Check again')),
            ),
            //
            // RESET GDPR and then GDPR CHECK AGAIN
            //
            const SizedBox(height: 32),
            ListTile(
              title: const Text(
                  'Reset GDPR and go to GDPR Check\n(returns on web)',
                  textAlign: TextAlign.center),
              subtitle: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            const GdprCheckWrapper(resetConfirmationForm: true),
                      ),
                    );
                  },
                  child: const Text('Reset GDPR and go to GDPR Check')),
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
    final res = '''
Status: ${interResponse == null ? '(not set)' : interResponse!.status.name}''';
    return res;
  }

  String _prettyInterRewardedStatus() {
    String res = '''
Status: (not set)
Reward amount: (not set)
Reward type: (not set)''';

    if (interRewardedResponse != null) {
      res = '''
Status: ${interRewardedResponse!.status.name}
Reward amount: ${interRewardedResponse!.rewardAmount}
Reward type: ${interRewardedResponse!.rewardType}''';
    }

    return res;
  }

  Future<void> _showInterRewardedAd(BuildContext context) async {
    final result = await AdService().showIntersitialRewarded(context);
    setState(() => interRewardedResponse = result);
  }

  Future<void> _showInterAd() async {
    final result = await AdService().showIntersitial();

    setState(() => interResponse = result);
  }
}
