/// The interstitial-rewared-ad can return all values.
enum StatusInterstitialRewarded {
  /// The app tried to load ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// AdService not initialized
  notLoadedInitialized,

  /// No ad ID(s) given
  notLoadedAdIdNotSet,

  /// If the ad is being loaded
  notLoadedButTryingTo,

  /// Ad had been shown right now
  displaySuccess,

  /// User denied seeing the ad in the confirmation dialog
  displayDeniedByUser,

  /// User aborts seeing the ad
  displayAbortedByUser,

  /// Ads disabled programmatically. Either when on Flutter Web or
  /// `disableAds()` has been called from within the code.
  displayDeniedProgrammatically,

  /// Ad failed to show for unspecific reason by Admob.
  displayFailedUnspecificReasons,
}

/// Response when failing or succeeding in showing an ad.
class ResponseInterstitialRewarded {
  StatusInterstitialRewarded status;
  num? rewardAmount;
  String? rewardType;
  int? admobErrorCode;
  String? admobErrorMessage;

  ResponseInterstitialRewarded(this.status,
      {this.rewardAmount,
      this.rewardType,
      this.admobErrorCode,
      this.admobErrorMessage});

  String prettyError() {
    String label = 'Admob Code:(none)\nAdmob Message:(none)';
    if (admobErrorCode != null) {
      label = 'Admob Code:$admobErrorCode\nAdmob Message:$admobErrorMessage';
    }
    return label;
  }
}
