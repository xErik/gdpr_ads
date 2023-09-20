import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../responsebanner.dart';

/// BannerService
class BannerServiceInstance {
  Completer<ResponseBanner> _completer = Completer<ResponseBanner>();
  bool _isLoading = false;

  final String _adUnitId;

  BannerServiceInstance(this._adUnitId);

  bool get isFetching => _isLoading;

  /// Call [fetchAd] before calling this method.
  Future<ResponseBanner> getAd() async => _completer.future;

  /// Fetches an ad in the background.
  void fetchAd() {
    _log('Preparing to fetch...');

    if (_isLoading == true) {
      _log('Already fetching, early abort');
    } else if (kIsWeb == true) {
      _completer.complete(ResponseBanner(StatusBanner.notLoadedOnWeb));
      _log('ads not available on the web, early abort');
    } else {
      _completer = Completer<ResponseBanner>();

      _log('Fetching ...');
      _isLoading = true;

      // no await
      BannerAd(
        adUnitId: _adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isLoading = false;
            _completer.complete(
                ResponseBanner(StatusBanner.loadedSuccess, ad: ad as BannerAd));
            _log('Loaded, completing: loadedSuccess');
          },
          onAdFailedToLoad: (ad, error) {
            _isLoading = false;
            ad.dispose();

            _completer.complete(ResponseBanner(StatusBanner.notLoadedGenerally,
                admobErrorCode: error.code, admobErrorMessage: error.message));
            _log(
                'Failed to load: ${error.code} ${error.message}, completing: notLoadedGenerally');
          },
        ),
      ).load();
    }
  }

  void _log(String text) =>
      kDebugMode ? log(text, name: runtimeType.toString()) : null;
}
