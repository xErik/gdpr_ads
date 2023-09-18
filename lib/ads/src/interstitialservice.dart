import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responseinterstitial.dart';

class InterstitialServiceInstance {
  Completer<ResponseInterstitial> _completer =
      Completer<ResponseInterstitial>();
  final String _adUnitId;
  InterstitialAd? _adToShow;

  InterstitialServiceInstance(this._adUnitId);

  /// Shows a confirmation dialog, if the user confirms it the ad is shown.
  /// The returned [ResponseInterstitial] details the ourtcome.
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseInterstitial> showAd() async {
    if (_completer.isCompleted == false) {
      if (_adToShow == null) {
        _completer.complete(
            ResponseInterstitial(StatusInterstitial.notLoadedGenerally));
      } else if (_adToShow != null) {
        await _adToShow?.show();

        // The ad may have been dismissed by user and the
        // completer already completed with that status.
        if (_completer.isCompleted == false) {
          _completer.complete(
              ResponseInterstitial(StatusInterstitial.displaySuccess));
        }
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
    } else {
      _log('Loading InterstitialAd');

      InterstitialAd.load(
        adUnitId: _adUnitId,
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
            _completer.complete(ResponseInterstitial(
                StatusInterstitial.notLoadedGenerally,
                admobErrorCode: error.code,
                admobErrorMessage: error.message));
          },
        ),
      );
    }
  }

  void _log(String text) => log(text, name: runtimeType.toString());
}
