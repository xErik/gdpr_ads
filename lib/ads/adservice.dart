import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'responsebanner.dart';
import 'responseinterstitial.dart';
import 'responseinterstitialrewarded.dart';
import 'src/bannerservice.dart';
import 'src/interstitialservice.dart';
import 'src/rewardedinterstitialservice.dart';

/// Facade for ad loading and displaying.
///
/// This is a Singleton class.
///
/// It allows to enable and disable ad initialaztion as well as  ad serving.
class AdService {
  bool _serveAds = true;
  List<String>? _testDeviceIds;

  final Map<String, BannerServiceInstance> _bannerMap = {};
  final Map<String, InterstitialServiceInstance> _intertsitialMap = {};
  final Map<String, RewardedInterstitialInstance> _interstitialRewardedMap = {};

  AdService._internal();
  static final AdService _singleton = AdService._internal();
  factory AdService() => _singleton;

  /// Disables ads.
  void disableAds() => _serveAds = false;

  /// Enables ads.
  void enableAds() => _serveAds = true;

  /// Sets test device IDs to get test ads
  void setTestDeviceIds(List<String>? testDeviceIds) {
    _testDeviceIds = testDeviceIds;
    _log('Set testDeviceIds: $testDeviceIds');
  }

  // --------------------------------------------------------------------------
  // ADD AD IDs
  // --------------------------------------------------------------------------

  /// Spins up an banner ad.
  /// Does nothing if serving ads is disabled.
  /// No need to [await].
  Future<void> addBanner(List<String> adUnitIds) async {
    if (_serveAds == false) {
      return;
    }
    for (String adUnitId in adUnitIds) {
      final instance = BannerServiceInstance();
      await instance.init(adUnitId, testDeviceIds: _testDeviceIds);
      instance.fetchAd();
      _bannerMap.putIfAbsent(adUnitId, () => instance);
      _log('Add bannerId: $adUnitId');
    }
  }

  /// Spins up an interstitial rewarded ad.
  /// Does nothing if serving ads is disabled.
  /// No need to [await].
  Future<void> addInterstitialRewarded(List<String> adUnitIds) async {
    if (_serveAds == false) {
      return;
    }
    for (String adUnitId in adUnitIds) {
      final instance = RewardedInterstitialInstance();
      await instance.init(adUnitId, testDeviceIds: _testDeviceIds);
      instance.fetchAd();
      _interstitialRewardedMap.putIfAbsent(adUnitId, () => instance);
      _log('Add interRewardedId: $adUnitId');
    }
  }

  /// Spins up an interstitial rewarded ad.
  /// Does nothing if serving ads is disabled.
  /// No need to [await].
  Future<void> addInterstitial(List<String> adUnitIds) async {
    if (_serveAds == false) {
      return;
    }
    for (String adUnitId in adUnitIds) {
      final instance = InterstitialServiceInstance();
      await instance.init(adUnitId, testDeviceIds: _testDeviceIds);
      instance.fetchAd();
      _intertsitialMap.putIfAbsent(adUnitId, () => instance);
      _log('Add intersitialId: $adUnitId');
    }
  }

  // --------------------------------------------------------------------------
  // SHOW ADs
  // --------------------------------------------------------------------------

  /// Use the widget [AdBanner] instead of using this method.
  /// Returns a [ResponseBanner] which contains a status and potentially a [BannerAd].
  Future<ResponseBanner> getBanner({String? adUnitId}) async {
    if (_serveAds == false) {
      return ResponseBanner(StatusBanner.displayDeniedProgrammatically);
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
      BuildContext context,
      {String? adUnitId}) async {
    if (_serveAds == false) {
      return ResponseInterstitialRewarded(
          StatusInterstitialRewarded.displayDeniedProgrammatically);
    }

    if (_interstitialRewardedMap[adUnitId] == null &&
        _interstitialRewardedMap.isEmpty) {
      return ResponseInterstitialRewarded(
          StatusInterstitialRewarded.notLoadedAdIdNotSet);
    }

    adUnitId ??= _interstitialRewardedMap.keys.first;

    final result =
        await _interstitialRewardedMap[adUnitId]!.showConfirmAdDialog(context);

    _interstitialRewardedMap[adUnitId]!.fetchAd(); // no await

    return result;
  }

  /// Returns a [ResponseInterstitial] which informs about the rewarded dialog.
  Future<ResponseInterstitial> showInterstitial({String? adUnitId}) async {
    if (_serveAds == false) {
      return ResponseInterstitial(
          StatusInterstitial.displayDeniedProgrammatically);
    }

    if (_intertsitialMap[adUnitId] == null && _intertsitialMap.isEmpty) {
      return ResponseInterstitial(StatusInterstitial.notLoadedAdIdNotSet);
    }

    adUnitId ??= _intertsitialMap.keys.first;

    final result = await _intertsitialMap[adUnitId]!.showAd();

    _intertsitialMap[adUnitId]!.fetchAd(); // no await

    return result;
  }

  _log(String text) => log(text, name: runtimeType.toString());
}
