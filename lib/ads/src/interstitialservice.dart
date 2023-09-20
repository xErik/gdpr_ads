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
  bool _isLoading = false;
  // ignore: unused_field
  bool _isShown = false;

  InterstitialServiceInstance(this._adUnitId);

  bool get isFetching => _isLoading;

  /// Shows a confirmation dialog, if the user confirms it the ad is shown.
  /// The returned [ResponseInterstitial] details the ourtcome.
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseInterstitial> showAd() async {
    if (_completer.isCompleted == false) {
      if (_adToShow == null) {
        _log('ad is NULL, early abort');
        _completer.complete(
            ResponseInterstitial(StatusInterstitial.notLoadedGenerally));
      } else if (_adToShow != null) {
        await _adToShow?.show();
        _log('show() starting ... ');

        if (_completer.isCompleted == false) {
          _isShown = true;
        }
      }
    }

    return _completer.future;
  }

  /// Fetches an ad in the background.
  /// No neet to `await` for it.
  void fetchAd() {
    _log('Preparing to fetch...');

    if (_isLoading == true) {
      _log('Already fetching, early abort');
    } else if (kIsWeb == true) {
      _completer
          .complete(ResponseInterstitial(StatusInterstitial.notLoadedOnWeb));
      _log('Ads not available on the web, early abort');
    } else {
      _completer = Completer<ResponseInterstitial>();
      _isShown = false;
      _adToShow = null;

      _log('Fetching ...');
      _isLoading = true;

      InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoading = false;
            _adToShow = ad;
            _log('Loaded');

            ad.fullScreenContentCallback =
                FullScreenContentCallback(onAdShowedFullScreenContent: (ad) {
              _log('  - onAdShowedFullScreenContent');
            }, onAdImpression: (ad) {
              _log('  - onAdImpression');
            }, onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _log(
                  '  - onAdFailedToShowFullScreenContent, completing: displayFailedUnspecificReasons');
              _completer.complete(
                  ResponseInterstitial(StatusInterstitial.notLoadedGenerally));
            }, onAdDismissedFullScreenContent: (ad) {
              ad.dispose();

              if (_isShown = true) {
                _log(
                    '  - onAdDismissedFullScreenContent, completing with: displaySuccess');
                _completer.complete(
                    ResponseInterstitial(StatusInterstitial.displaySuccess));
              } else {
                _log(
                    '  - onAdDismissedFullScreenContent, completing with: displayFailedUnspecificReasons');
                _completer.complete(ResponseInterstitial(
                    StatusInterstitial.displayFailedUnspecificReasons));
              }
            }, onAdClicked: (ad) {
              _log('  - onAdClicked');
            });
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _log(
                'Failed to load: ${error.code} ${error.message}, completing: notLoadedGenerally');
            _completer.complete(ResponseInterstitial(
                StatusInterstitial.notLoadedGenerally,
                admobErrorCode: error.code,
                admobErrorMessage: error.message));
          },
        ),
      );
    }
  }

  void _log(String text) =>
      kDebugMode ? log(text, name: runtimeType.toString()) : null;
}
