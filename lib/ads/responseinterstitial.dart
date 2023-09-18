/// The interstitial-rewared-ad can return all values.
enum StatusInterstitial {
  /// The app tried to laods ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// Service instance has no ad to load
  notLoadedAdIdNotSet,

  /// Ad had been shown right now
  displaySuccess,

  /// User denied seeing the ad in the confirmation dialog
  // displayDeniedByUser,

  /// Ads disabled programmatically
  displayDeniedProgrammatically,
}

/// Response when failing or succeeding in showing an ad.

/// Call `ad!.show()` to display the interstitial ad.
class ResponseInterstitial {
  StatusInterstitial status;
  // InterstitialAd? ad;

  ResponseInterstitial(this.status);
}