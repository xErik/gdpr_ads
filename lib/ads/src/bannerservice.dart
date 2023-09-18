import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responsebanner.dart';

/// BannerService
class BannerServiceInstance {
  Completer<ResponseBanner> _completer = Completer<ResponseBanner>();

  final String _adUnitId;

  BannerServiceInstance(this._adUnitId);

  /// Call [fetchAd] before calling this method.
  Future<ResponseBanner> getAd() async => _completer.future;

  /// Fetches an ad in the background.
  void fetchAd() {
    _completer = Completer<ResponseBanner>();

    if (kIsWeb == true) {
      _completer.complete(ResponseBanner(StatusBanner.notLoadedOnWeb));
      _log('Aborted loading BannerAd: ads not available on the web');
    } else {
      // no await
      BannerAd(
        adUnitId: _adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _completer.complete(
                ResponseBanner(StatusBanner.loadedSuccess, ad: ad as BannerAd));
            _log('BannerAd loaded');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();

            _completer.complete(ResponseBanner(StatusBanner.notLoadedGenerally,
                admobErrorCode: error.code, admobErrorMessage: error.message));
            _log('BannerAd failed to load: ${error.code} ${error.message}');
          },
        ),
      ).load();
    }
  }

  void _log(String text) => log(text, name: runtimeType.toString());
}
