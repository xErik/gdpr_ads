import 'config_ignored.dart';

class Config {
  // -------------------------------------------------------------------------------
  // AD IDs ANDROID
  // -------------------------------------------------------------------------------

  /// DUMMY ADS
  ///
  /// https://developers.google.com/admob/android/test-ads#sample_ad_units
  ///
  /// App Open 	ca-app-pub-3940256099942544/3419835294
  /// Adaptive Banner 	ca-app-pub-3940256099942544/9214589741
  /// Banner 	ca-app-pub-3940256099942544/6300978111
  /// Interstitial 	ca-app-pub-3940256099942544/1033173712
  /// Interstitial Video 	ca-app-pub-3940256099942544/8691691433
  /// Rewarded 	ca-app-pub-3940256099942544/5224354917
  /// Rewarded Interstitial 	ca-app-pub-3940256099942544/5354046379
  /// Native Advanced 	ca-app-pub-3940256099942544/2247696110
  /// Native Advanced Video 	ca-app-pub-3940256099942544/1044960115

  static String get interRewardAdId => "ca-app-pub-3940256099942544/5354046379";

  static String get bannerAdId => "ca-app-pub-3940256099942544/6300978111";

  static String get interstitialAdId =>
      "ca-app-pub-3940256099942544/1033173712";

  static List<String> get testDeviceIds => ConfigIgnored.testDeviceIds;
}
