import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Response when failing or succeeding in showing an ad.
class ResponseBanner {
  StatusBanner status;
  BannerAd? ad;

  ResponseBanner(this.status, {this.ad});

  bool hasAd() => ad != null;
}

/// The interstitial-rewared-ad can return all values.
enum StatusBanner {
  /// The app tried to laods ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// Failed to load the ad in case of GDPR denial etc.
  notLoadedAdIdNotSet,

  // Ad had been shown right now
  displaySuccess
}
