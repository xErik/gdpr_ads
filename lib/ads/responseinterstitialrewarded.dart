/// The interstitial-rewared-ad can return all values.
enum StatusInterstitialRewarded {
  /// The app tried to laods ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// No ad ID(s) given
  notLoadedAdIdNotSet,

  // Ad had been shown right now
  displaySuccess,

  // User denied seeing the ad in the confirmation dialog
  displayDeniedByUser,

  /// Ads disabled programmatically
  displayDeniedProgrammatically,
}

/// Response when failing or succeeding in showing an ad.
class ResponseInterstitialRewarded {
  StatusInterstitialRewarded status;
  num? rewardAmount;
  String? rewardType;

  ResponseInterstitialRewarded(
    this.status, {
    this.rewardAmount,
    this.rewardType,
  });
}