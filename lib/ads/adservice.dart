import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'responsebanner.dart';
import 'responseintersitial.dart';
import 'responseintersitialrewarded.dart';
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
  final Map<String, InterstitialServiceInstance> _intersitialMap = {};
  final Map<String, RewardedInterstitialInstance> _intersitialRewardedMap = {};

  AdService._internal();
  static final AdService _singleton = AdService._internal();
  factory AdService() => _singleton;

  /// Disables ads.
  void disableAds() => _serveAds = false;

  /// Enables ads.
  void enableAds() => _serveAds = true;

  /// Sets test device IDs to get test ads
  void setTestDeviceIds(List<String>? testDeviceIds) =>
      _testDeviceIds = testDeviceIds;

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
      await instance.fetchAd();
      _bannerMap.putIfAbsent(adUnitId, () => instance);
    }
  }

  /// Spins up an intersitial rewarded ad.
  /// Does nothing if serving ads is disabled.
  /// No need to [await].
  Future<void> addIntersitialRewarded(List<String> adUnitIds) async {
    if (_serveAds == false) {
      return;
    }
    for (String adUnitId in adUnitIds) {
      final instance = RewardedInterstitialInstance();
      await instance.init(adUnitId, testDeviceIds: _testDeviceIds);
      await instance.fetchAd();
      _intersitialRewardedMap.putIfAbsent(adUnitId, () => instance);
    }
  }

  /// Spins up an intersitial rewarded ad.
  /// Does nothing if serving ads is disabled.
  /// No need to [await].
  Future<void> addIntersitial(List<String> adUnitIds) async {
    if (_serveAds == false) {
      return;
    }
    for (String adUnitId in adUnitIds) {
      final instance = InterstitialServiceInstance();
      await instance.init(adUnitId, testDeviceIds: _testDeviceIds);
      await instance.fetchAd();
      _intersitialMap.putIfAbsent(adUnitId, () => instance);
    }
  }

  // --------------------------------------------------------------------------
  // SHOW ADs
  // --------------------------------------------------------------------------

  /// Use the widget [AdBanner] instead of using this method.
  /// Returns a [ResponseBanner] which contains a status and potentially a [BannerAd].
  /// Returns NULL is serving ads is disabled.
  Future<ResponseBanner?> showBanner({String? adUnitId}) async {
    if (_serveAds == false) {
      return null;
    }

    if (adUnitId != null) {
      if (_bannerMap[adUnitId] == null) {
        throw 'Banner-adUnitId not set, add it before calling this method.';
      }
    } else {
      if (_bannerMap.isEmpty) {
        throw 'Banner-adUnitId not set, can cannot find a substitute';
      }
      adUnitId = _bannerMap.keys.first;
    }

    return await _bannerMap[adUnitId]!.getAd();
  }

  /// Returns a [ResponseInterstitialRewarded] which informs about the rewarded dialog.
  /// Returns NULL is serving ads is disabled.
  Future<ResponseInterstitialRewarded?> showIntersitialRewarded(
      BuildContext context,
      {String? adUnitId}) async {
    if (_serveAds == false) {
      return null;
    }

    if (adUnitId != null) {
      if (_intersitialRewardedMap[adUnitId] == null) {
        throw 'InterstitialRewarded-adUnitId not set, add it before calling this method.';
      }
    } else {
      if (_intersitialRewardedMap.isEmpty) {
        throw 'InterstitialRewarded-adUnitId not set, can cannot find a substitute';
      }
      adUnitId = _intersitialRewardedMap.keys.first;
    }

    return await _intersitialRewardedMap[adUnitId]!
        .showConfirmAdDialog(context);
  }

  /// Returns a [ResponseInterstitial] which informs about the rewarded dialog.
  /// Returns NULL is serving ads is disabled.
  Future<ResponseInterstitial?> showIntersitial({String? adUnitId}) async {
    if (_serveAds == false) {
      return null;
    }

    if (adUnitId != null) {
      if (_intersitialMap[adUnitId] == null) {
        throw 'Interstitial-adUnitId not set, add it before calling this method.';
      }
    } else {
      if (_intersitialMap.isEmpty) {
        throw 'Interstitial-adUnitId not set, can cannot find a substitute';
      }
      adUnitId = _intersitialMap.keys.first;
    }

    return await _intersitialMap[adUnitId]!.showAd();
  }
}
