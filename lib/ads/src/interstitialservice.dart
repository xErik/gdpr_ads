import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responseinterstitial.dart';

class InterstitialServiceInstance {
  Completer<ResponseInterstitial> _completer =
      Completer<ResponseInterstitial>();
  String? _adUnitId;
  InterstitialAd? _adToShow;

  /// Initializes [MobileAds].
  Future<void> init(String adUnitId, {List<String>? testDeviceIds}) async {
    if (kIsWeb == false) {
      _adUnitId = adUnitId;
      await MobileAds.instance.initialize();

      final old = await MobileAds.instance.getRequestConfiguration();
      final cnf = RequestConfiguration(
          maxAdContentRating: old.maxAdContentRating,
          tagForChildDirectedTreatment: old.tagForChildDirectedTreatment,
          tagForUnderAgeOfConsent: old.tagForUnderAgeOfConsent,
          testDeviceIds: testDeviceIds);
      await MobileAds.instance.updateRequestConfiguration(cnf);
    }
  }

  /// Shows a confirmation dialog, if the user confirms it the ad is shown.
  /// The returned [ResponseInterstitial] details the ourtcome.
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseInterstitial> showAd() async {
    if (_adToShow == null) {
      _completer.complete(
          ResponseInterstitial(StatusInterstitial.notLoadedGenerally));
    } else if (_adToShow != null) {
      await _adToShow?.show();

      // The ad may have been dismissed by user and the
      // completer already completed with that status.
      if (_completer.isCompleted == false) {
        _completer
            .complete(ResponseInterstitial(StatusInterstitial.displaySuccess));
      }
    }

    return _completer.future;
  }

  /// Fetches an ad in the background.
  /// No neet to `await` for it.
  void fetchAd() {
    _completer = Completer<ResponseInterstitial>();

    if (kIsWeb == true) {
      _completer
          .complete(ResponseInterstitial(StatusInterstitial.notLoadedOnWeb));
      _log('Aborted loading InterstitialAd: ads not available on the web');
    } else if (_adUnitId == null) {
      _completer.complete(
          ResponseInterstitial(StatusInterstitial.notLoadedAdIdNotSet));
      _log(
          'Aborted loading InterstitialAd: init() not called, GDPR denied or error?');
    } else {
      _log('Loading InterstitialAd');

      InterstitialAd.load(
        adUnitId: _adUnitId!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {
                  _completer.complete(
                      ResponseInterstitial(StatusInterstitial.displaySuccess));
                },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  _completer.complete(ResponseInterstitial(
                      StatusInterstitial.notLoadedGenerally));
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            _adToShow = ad;
            _log('InterstitialAd loaded');
          },
          onAdFailedToLoad: (error) {
            _log(
                'InterstitialAd failed to load: ${error.code} ${error.message}');
            _completer.complete(
                ResponseInterstitial(StatusInterstitial.notLoadedGenerally));
          },
        ),
      );
    }
  }

  void _log(String text) => log(text, name: runtimeType.toString());
}
