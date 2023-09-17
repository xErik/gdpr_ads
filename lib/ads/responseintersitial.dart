/// The interstitial-rewared-ad can return all values.
enum StatusInterstitial {
  /// The app tried to laods ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// Failed to load the ad in case of GDPR denial etc.
  notLoadedAdIdNotSet,

  // Ad had been shown right now
  displaySuccess,
  // User denied seeing the ad in the confirmation dialog
  displayDeniedByUser
}

/// Response when failing or succeeding in showing an ad.

/// Call `ad!.show()` to display the intersitial ad.
class ResponseInterstitial {
  StatusInterstitial status;
  // InterstitialAd? ad;

  ResponseInterstitial(this.status);
}
