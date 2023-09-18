import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Response when failing or succeeding in showing an ad.
class ResponseBanner {
  StatusBanner status;
  BannerAd? ad;
  int? admobErrorCode;
  String? admobErrorMessage;

  ResponseBanner(this.status,
      {this.ad, this.admobErrorCode, this.admobErrorMessage});

  bool hasAd() => ad != null;

  String prettyError() {
    String label = 'No banner loaded, because: ${status.name}';
    if (admobErrorCode != null) {
      label += ' code:$admobErrorCode message:$admobErrorMessage';
    }
    return label;
  }
}

/// The interstitial-rewared-ad can return all values.
enum StatusBanner {
  /// The app tried to laods ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// Failed to load the ad in case of GDPR denial etc.
  notLoadedAdIdNotSet,

  /// Ad had been loaded
  loadedSuccess,

  /// Ads disabled programmatically
  displayDeniedProgrammatically,
}
