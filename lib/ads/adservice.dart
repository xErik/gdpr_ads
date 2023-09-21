import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'responsebanner.dart';
import 'responseinterstitial.dart';
import 'responseinterstitialrewarded.dart';
import 'src/bannerservice.dart';
import 'src/interstitialservice.dart';
import 'src/rewardedinterstitialservice.dart';

/// Facade for Ad loading and displaying.
///
/// This is a Singleton class.
///
/// It allows to enable and disable Ad initialization as well as Ad serving.
class AdService {
  bool _serveAds = true;
  bool _isInitialized = false;

  final Map<String, BannerServiceInstance> _bannerMap = {};
  final Map<String, InterstitialServiceInstance> _intertsitialMap = {};
  final Map<String, RewardedInterstitialInstance> _interstitialRewardedMap = {};

  AdService._internal();
  static final AdService _singleton = AdService._internal();
  factory AdService() => _singleton;

  // --------------------------------------------------------------------------
  //
  // --------------------------------------------------------------------------

  /// Disables ad initialization and loading.
  void disableAds() => _serveAds = false;

  /// Enables ad initialization and loading.
  void enableAds() => _serveAds = true;

  // Wether service is disabled. Always disabled in web.
  bool isDisabledProgrammatically() => _serveAds == false || kIsWeb == true;

  // --------------------------------------------------------------------------
  //
  // --------------------------------------------------------------------------

  /// Initializes and resets this service class.
  /// In case of [disableAds] or [kIsWeb] the initialization will not complete.
  ///
  /// It is save to call this method even if user has DENIED the GDPR confirmation
  /// dialog. In this case, Admob will refrain from delivering ads.
  void initialize(
      {List<String> bannerIds = const [],
      List<String> interstitialIds = const [],
      List<String> interRewardIds = const [],
      List<String> testDeviceIds = const []}) async {
    _bannerMap.clear();
    _intertsitialMap.clear();
    _interstitialRewardedMap.clear();

    if (isDisabledProgrammatically()) {
      _isInitialized = false;
      return;
    }

    await MobileAds.instance.initialize();
    final old = await MobileAds.instance.getRequestConfiguration();
    final cnf = RequestConfiguration(
        maxAdContentRating: old.maxAdContentRating,
        tagForChildDirectedTreatment: old.tagForChildDirectedTreatment,
        tagForUnderAgeOfConsent: old.tagForUnderAgeOfConsent,
        testDeviceIds: testDeviceIds);
    await MobileAds.instance.updateRequestConfiguration(cnf);

    for (String adUnitId in bannerIds) {
      final instance = BannerServiceInstance(adUnitId);
      instance.fetchAd();
      _bannerMap.putIfAbsent(adUnitId, () => instance);
      _log('Added bannerId: $adUnitId');
    }

    for (String adUnitId in interstitialIds) {
      final instance = InterstitialServiceInstance(adUnitId);
      instance.fetchAd();
      _intertsitialMap.putIfAbsent(adUnitId, () => instance);
      _log('Added intersitialId: $adUnitId');
    }

    for (String adUnitId in interRewardIds) {
      final instance = RewardedInterstitialInstance(adUnitId);
      instance.fetchAd();
      _interstitialRewardedMap.putIfAbsent(adUnitId, () => instance);
      _log('Added interRewardedId: $adUnitId');
    }

    _isInitialized = true;
  }

  // --------------------------------------------------------------------------
  // SHOW ADs
  // --------------------------------------------------------------------------

  /// Use the widget [AdBanner] instead of using this method.
  ///
  /// Returns a [ResponseBanner] which contains a status and potentially a [BannerAd].
  Future<ResponseBanner> getBanner({String? adUnitId}) async {
    if (isDisabledProgrammatically()) {
      return ResponseBanner(StatusBanner.displayDeniedProgrammatically);
    }

    if (_isInitialized == false) {
      return ResponseBanner(StatusBanner.notLoadedInitialized);
    }

    if (_bannerMap[adUnitId] == null && _bannerMap.isEmpty) {
      return ResponseBanner(StatusBanner.notLoadedAdIdNotSet);
    }

    adUnitId ??= _bannerMap.keys.first;

    final result = await _bannerMap[adUnitId]!.getAd();
    _bannerMap[adUnitId]!.fetchAd(); // no await
    return result;
  }

  /// Returns a [ResponseInterstitialRewarded] which informs about the rewarded dialog.
  Future<ResponseInterstitialRewarded> showInterstitialRewarded(
      BuildContext context, Widget confirmDialog,
      {String? adUnitId}) async {
    if (isDisabledProgrammatically()) {
      return ResponseInterstitialRewarded(
          StatusInterstitialRewarded.displayDeniedProgrammatically);
    }

    if (_isInitialized == false) {
      return ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedInitialized);
    }

    if (_interstitialRewardedMap[adUnitId] == null &&
        _interstitialRewardedMap.isEmpty) {
      return ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedAdIdNotSet);
    }

    adUnitId ??= _interstitialRewardedMap.keys.first;

    if (_interstitialRewardedMap[adUnitId]!.isFetching) {
      return ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedButTryingTo);
    }

    final result = await _interstitialRewardedMap[adUnitId]!
        .showConfirmAdDialog(confirmDialog, context);
    _interstitialRewardedMap[adUnitId]!.fetchAd(); // no await
    return result;
  }

  /// Returns a [ResponseInterstitial] which informs about the rewarded dialog.
  Future<ResponseInterstitial> showInterstitial({String? adUnitId}) async {
    if (isDisabledProgrammatically()) {
      return ResponseInterstitial(
          StatusInterstitial.displayDeniedProgrammatically);
    }

    if (_isInitialized == false) {
      return ResponseInterstitial(StatusInterstitial.notLoadedInitialized);
    }

    if (_intertsitialMap[adUnitId] == null && _intertsitialMap.isEmpty) {
      return ResponseInterstitial(StatusInterstitial.notLoadedAdIdNotSet);
    }

    adUnitId ??= _intertsitialMap.keys.first;

    if (_intertsitialMap[adUnitId]!.isFetching) {
      return ResponseInterstitial(StatusInterstitial.notLoadedButTryingTo);
    }

    final result = await _intertsitialMap[adUnitId]!.showAd();
    _intertsitialMap[adUnitId]!.fetchAd(); // no await
    return result;
  }

  /// Hook to process the outcome of a a Rewarded Interstital Ad.
  ///
  /// See [RewardedInterstitialDialog] on how to use this hook.
  void interstitialRewardedShowAdHook({String? adUnitId}) {
    if (_interstitialRewardedMap[adUnitId] == null &&
        _interstitialRewardedMap.isEmpty) {
      throw 'adUnitId is not given and there is no alternative RewardedInterstitial is available.';
    }

    adUnitId ??= _interstitialRewardedMap.keys.first;

    _interstitialRewardedMap[adUnitId]!.showAdHook();
  }

  /// Hook to process the outcome of a a Rewarded Interstital Ad.
  ///
  /// See [RewardedInterstitialDialog] on how to use this hook.
  void interstitialRewardedShowNoAdHook({String? adUnitId}) {
    if (_interstitialRewardedMap[adUnitId] == null &&
        _interstitialRewardedMap.isEmpty) {
      throw 'adUnitId is not given and there is no alternative RewardedInterstitial is available.';
    }

    adUnitId ??= _interstitialRewardedMap.keys.first;

    _interstitialRewardedMap[adUnitId]!.showNoAdHook();
  }

  _log(String text) => log(text, name: runtimeType.toString());
}
