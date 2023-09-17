import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responsebanner.dart';

/// BannerService
class BannerServiceInstance {
  Completer<ResponseBanner> _completer = Completer<ResponseBanner>();

  /// Is NULL if [init] has not been called due to GDPR denial
  String? _adUnitId;

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

  /// Will load an ad if:
  /// 1. Not in web context
  /// 2. An addId has been set in [init]
  ///
  /// Call [fetchAd] before calling this method.
  Future<ResponseBanner> getAd() async => _completer.future;

  /// A result may be an ad but also a failure to load an ed.
  // bool get hasAdResult => _completer.isCompleted;

  /// Fetches an ad in the background.
  /// No neet to `await` for it.
  Future<void> fetchAd() async {
    _completer = Completer<ResponseBanner>();

    if (kIsWeb == true) {
      _completer.complete(ResponseBanner(StatusBanner.notLoadedOnWeb));
      _log('Aborted loading BannerAd: ads not available on the web');
    } else if (_adUnitId == null) {
      _completer.complete(ResponseBanner(StatusBanner.notLoadedAdIdNotSet));
      _log(
          'Aborted loading BannerAd: init() not called, GDPR denied or error?');
    } else {
      await BannerAd(
        adUnitId: _adUnitId!,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _completer.complete(ResponseBanner(StatusBanner.displaySuccess,
                ad: ad as BannerAd));
            _log('BannerAd loaded');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _completer
                .complete(ResponseBanner(StatusBanner.notLoadedGenerally));
            _log('BannerAd failed to load: ${error.code} ${error.message}');
          },
        ),
      ).load();
    }
  }

  void _log(String text) => log(text, name: runtimeType.toString());
}
