import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responseinterstitialrewarded.dart';

class RewardedInterstitialInstance {
  Completer<ResponseInterstitialRewarded> _completer =
      Completer<ResponseInterstitialRewarded>();
  final String _adUnitId;
  RewardedInterstitialAd? _adToShow;
  bool _isLoading = false;
  RewardItem? _rewardItem;

  RewardedInterstitialInstance(this._adUnitId);

  bool get isFetching => _isLoading;

  /// Shows a confirmation dialog, if user confirms the ad is shown.
  /// The confirmation dialog is not shown in case the ad is not loaded.
  ///
  /// The returned [ResponseInterstitialRewarded] details the ourtcome.
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseInterstitialRewarded> showConfirmAdDialog(
      Widget dialog, BuildContext context) async {
    _log('Preparing confirm dialog ...');

    /// The completer may indicate failed loading in [fetchAd].
    if (_completer.isCompleted == false) {
      if (_adToShow == null) {
        _log('ad is NULL, early abort');
        _completer.complete(ResponseInterstitialRewarded(
            StatusInterstitialRewarded.notLoadedGenerally));
      } else {
        _log('Confirm dialog ...');

        await showDialog<StatusInterstitialRewarded>(
          context: context,
          builder: (_) => dialog,

          // DialogConfirmAd(showNoAd: () {
          //   _log('showNoAd(), completing with: displayDeniedByUser');
          //   _completer.complete(ResponseInterstitialRewarded(
          //       StatusInterstitialRewarded.displayDeniedByUser));
          // }, showAd: () {
          // _log('showAd()');
          // _adToShow?.show(
          //   onUserEarnedReward: (AdWithoutView view, RewardItem rewardItem) {
          //     _log('  - onUserEarnedReward');
          //     _rewardItem = rewardItem;
          //   },
          // );
          // }),
        );
      }
    }
    return _completer.future;
  }

  void showNoAdHook() {
    _log('showNoAd(), completing with: displayDeniedByUser');
    _completer.complete(ResponseInterstitialRewarded(
        StatusInterstitialRewarded.displayDeniedByUser));
  }

  void showAdHook() {
    _log('showAd()');
    _adToShow?.show(
      onUserEarnedReward: (AdWithoutView view, RewardItem rewardItem) {
        _log('  - onUserEarnedReward');
        _rewardItem = rewardItem;
      },
    );
  }

  /// Fetches an ad in the background.
  void fetchAd() {
    _log('Preparing to fetch...');

    if (_isLoading == true) {
      _log('Already fetching, early abort');
    } else if (kIsWeb == true) {
      _completer.complete(ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedOnWeb));
      _log('Ads not available on the web, early abort');
    } else {
      _completer = Completer<ResponseInterstitialRewarded>();
      _adToShow = null;
      _rewardItem = null;

      _log('Fetching ...');
      _isLoading = true;

      RewardedInterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _adToShow = ad;
            _isLoading = false;
            _log('Ad loaded');

            ad.fullScreenContentCallback =
                FullScreenContentCallback(onAdShowedFullScreenContent: (ad) {
              _log('  - onAdShowedFullScreenContent');
            }, onAdImpression: (ad) {
              _log('  - onAdImpression');
            }, onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _log(
                  '  - onAdFailedToShowFullScreenContent, completing: displayFailedUnspecificReasons');

              _completer.complete(ResponseInterstitialRewarded(
                  StatusInterstitialRewarded.displayFailedUnspecificReasons));
            }, onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (_rewardItem != null) {
                _log(
                    '  - onAdDismissedFullScreenContent, completing: displaySuccess');
                _completer.complete(ResponseInterstitialRewarded(
                  StatusInterstitialRewarded.displaySuccess,
                  rewardAmount: _rewardItem!.amount,
                  rewardType: _rewardItem!.type,
                ));
              } else {
                _log(
                    '  - onAdDismissedFullScreenContent, completing: displayAbortedByUser');
                _completer.complete(ResponseInterstitialRewarded(
                    StatusInterstitialRewarded.displayAbortedByUser));
              }
            }, onAdClicked: (ad) {
              _log('  - onAdClicked');
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isLoading = false;
            _log(
                '  - Failed to load: ${error.code} ${error.message}, completing: notLoadedGenerally');
            _completer.complete(ResponseInterstitialRewarded(
                StatusInterstitialRewarded.notLoadedGenerally,
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
