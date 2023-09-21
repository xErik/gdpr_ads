/// The interstitial-rewared-ad can return all values.
enum StatusInterstitial {
  /// The app tried to laods ads on Flutter Web, which is not supported
  notLoadedOnWeb,

  /// Failed to load the ad
  notLoadedGenerally,

  /// AdService not initialized
  notLoadedInitialized,

  /// Service instance has no ad to load
  notLoadedAdIdNotSet,

  /// If the ad is being loaded
  notLoadedButTryingTo,

  /// Ad had been shown right now
  displaySuccess,

  /// Ads disabled programmatically
  displayDeniedProgrammatically,

  /// Ad failed to show for unspecific reason
  displayFailedUnspecificReasons,
}

/// Response when failing or succeeding in showing an ad.

/// Call `ad!.show()` to display the interstitial ad.
class ResponseInterstitial {
  StatusInterstitial status;
  int? admobErrorCode;
  String? admobErrorMessage;

  ResponseInterstitial(this.status,
      {this.admobErrorCode, this.admobErrorMessage});

  String prettyError() {
    String label = 'Admob Code:(none)\nAdmob Message:(none)';
    if (admobErrorCode != null) {
      label = 'Admob Code:$admobErrorCode\nAdmob Message:$admobErrorMessage';
    }
    return label;
  }
}
