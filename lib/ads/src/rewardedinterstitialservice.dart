import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responseinterstitialrewarded.dart';
import 'dialogconfirmad.dart';

class RewardedInterstitialInstance {
  Completer<ResponseInterstitialRewarded> _completer =
      Completer<ResponseInterstitialRewarded>();
  final String _adUnitId;
  RewardedInterstitialAd? _adToShow;

  RewardedInterstitialInstance(this._adUnitId);

  /// Shows a confirmation dialog, if user confirms the ad is shown.
  /// The confirmation dialog is not shown in case the ad is not loaded.
  ///
  /// The returned [ResponseInterstitialRewarded] details the ourtcome.
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseInterstitialRewarded> showConfirmAdDialog(
      BuildContext context) async {
    _log('Checking RewardedInterstitialAd confirm dialog ...');

    /// The completer may indicate failed loading in [fetchAd].
    if (_completer.isCompleted == false) {
      if (_adToShow == null) {
        _log('Aborting, _adToShow is NULL');

        _completer.complete(ResponseInterstitialRewarded(
            StatusInterstitialRewarded.notLoadedGenerally));
      } else {
        _log('Opening RewardedInterstitialAd confirm dialog ...');

        await showDialog<StatusInterstitialRewarded>(
          context: context,
          builder: (_) => DialogConfirmAd(showNoAd: () {
            _log('Opening RewardedInterstitialAd showNoAd()');
            _completer.complete(ResponseInterstitialRewarded(
                StatusInterstitialRewarded.displayDeniedByUser));
          }, showAd: () {
            // _log('Opening RewardedInterstitialAd showAd()');
            _adToShow?.show(
              onUserEarnedReward: (AdWithoutView view, RewardItem rewardItem) {
                // Called on success.
                // The completer is not completed at this point.
                _log('InterstitialRewardedAd onUserEarnedReward');
                _completer.complete(
                  ResponseInterstitialRewarded(
                    StatusInterstitialRewarded.displaySuccess,
                    rewardAmount: rewardItem.amount,
                    rewardType: rewardItem.type,
                  ),
                );
              },
            );
          }),
        );
      }
    }
    return _completer.future;
  }

  /// Fetches an ad in the background.
  void fetchAd() {
    _log('Checking fetching RewardedInterstitialAd ...');

    _completer = Completer<ResponseInterstitialRewarded>();
    _adToShow = null;

    if (kIsWeb == true) {
      _completer.complete(ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedOnWeb));
      _log(
          'Aborted loading RewardedInterstitialAd: ads not available on the web');
    } else {
      _log('Loading RewardedInterstitialAd...');

      RewardedInterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {
              // Succes handling is donw in:
              // _adToShow?.show( onUserEarnedReward
              //
              // Do NOT handle that here.
              _log('InterstitialRewardedAd onAdShowedFullScreenContent');
            },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {
              _log('InterstitialRewardedAd onAdImpression');
            },
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();

              // Is this true:
              // Did the user cut the ad short?
              // @TODO

              _log('InterstitialRewardedAd onAdFailedToShowFullScreenContent');

              _completer.complete(ResponseInterstitialRewarded(
                  StatusInterstitialRewarded.displayDeniedByUser));
            },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
              _log('InterstitialRewardedAd onAdDismissedFullScreenContent');
              // This happens when onUserEarnedReward() had not been called,
              // which means the user dismissed the add.
              // Thus, it needs to get completed here.
              if (_completer.isCompleted == false) {
                _completer.complete(ResponseInterstitialRewarded(
                    StatusInterstitialRewarded.displayDeniedByUser));
              }

              ad.dispose();
            },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {
              _log('InterstitialRewardedAd onAdClicked');
            });

            _adToShow = ad;
            _log('InterstitialRewardedAd loaded');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _log(
                'RewardedInterstitialAd failed to load: ${error.code} ${error.message}');
            _completer.complete(ResponseInterstitialRewarded(
                StatusInterstitialRewarded.notLoadedGenerally,
                admobErrorCode: error.code,
                admobErrorMessage: error.message));
          },
        ),
      );
    }
  }

  void _log(String text) => log(text, name: runtimeType.toString());
}
