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
  String? _adUnitId;
  RewardedInterstitialAd? _adToShow;

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

  /// Shows a confirmation dialog, if user confirms the ad is shown.
  /// The confirmation dialog is not shown in case the ad is not loaded.
  ///
  /// The returned [ResponseInterstitialRewarded] details the ourtcome.
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseInterstitialRewarded> showConfirmAdDialog(
      BuildContext context) async {
    _log('Checking ad confirm dialog ...');

    /// The completer may indicate failed loading in [fetchAd].
    if (_completer.isCompleted == false) {
      if (_adToShow == null) {
        _completer.complete(ResponseInterstitialRewarded(
            StatusInterstitialRewarded.notLoadedGenerally));
      } else {
        await showDialog<StatusInterstitialRewarded>(
          context: context,
          builder: (_) => DialogConfirmAd(showNoAd: () {
            _completer.complete(ResponseInterstitialRewarded(
                StatusInterstitialRewarded.displayDeniedByUser));
          }, showAd: () {
            _adToShow?.show(
              onUserEarnedReward: (AdWithoutView view, RewardItem rewardItem) {
                // Called on success.
                // The completer is not completed at this point.
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
    _completer = Completer<ResponseInterstitialRewarded>();
    _adToShow = null;

    if (kIsWeb == true) {
      _completer.complete(ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedOnWeb));
      _log(
          'Aborted loading RewardedInterstitialAd: ads not available on the web');
    } else if (_adUnitId == null) {
      _completer.complete(ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedAdIdNotSet));
      _log(
          'Aborted loading RewardedInterstitialAd: init() not called, GDPR denied or error?');
    } else {
      _log('Loading RewardedInterstitialAd...');

      RewardedInterstitialAd.load(
        adUnitId: _adUnitId!,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  _completer.complete(ResponseInterstitialRewarded(
                      StatusInterstitialRewarded.notLoadedGenerally));
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _completer.complete(ResponseInterstitialRewarded(
                      StatusInterstitialRewarded.displayDeniedByUser));
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            _adToShow = ad;
            _log('InterstitialRewardedAd loaded');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _log(
                'RewardedInterstitialAd failed to load: ${error.code} ${error.message}');
            _completer.complete(ResponseInterstitialRewarded(
                StatusInterstitialRewarded.notLoadedGenerally));
          },
        ),
      );
    }
  }

  void _log(String text) => log(text, name: runtimeType.toString());
}
