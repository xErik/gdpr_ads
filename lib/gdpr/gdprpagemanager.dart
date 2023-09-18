import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';
import 'package:gdpr_ads/gdpr/gdprupdatepage.dart';

import 'gdprinitialpage.dart';

/// Singleton Helper class to initiate Gdpr and Ads only once.
///
/// And then access [GdprInitialPage] and [GdprUpdatePage]
/// via [getInitialPage] and [getUpdateage].
///
/// Usage:
///
/// ```dart
/// GdprPageManager( ... params ...);
///
/// GdprPageManager( ... params ...).initialPage();
///
/// Scaffold(body:
///   GdprPageManager.singleton.initialPage());
///
/// Scaffold(body:
///   GdprPageManager.singleton.initialResetPage());
///
/// Scaffold(body:
///   GdprPageManager.singleton.updatePage());
/// ```
///
class GdprPageManager {
  late VoidCallback _onNavigationMethod;
  //
  late List<String> _bannerIds;
  late List<String> _interstitialIds;
  late List<String> _interRewardIds;
  late List<String> _debugTestDeviceIds;
  //
  late Widget _loadingWidget;
  late GdprDebugGeography _debugGeography;
  late bool _showDebugUI;

  GdprPageManager._internal();
  static final GdprPageManager singleton = GdprPageManager._internal();

  /// Initializes this singleton
  factory GdprPageManager(
    final VoidCallback onNavigationMethod, {
    final List<String> bannerIds = const [],
    final List<String> interstitialIds = const [],
    final List<String> interRewardIds = const [],
    final List<String> debugTestDeviceIds = const [],
    final Widget loadingWidget =
        const Center(child: CircularProgressIndicator()),
    final GdprDebugGeography debugGeography = GdprDebugGeography.disabled,
    // final List<String> debugTestIdentifiers = const [],
    final bool debugShowDebugUI = false,
  }) =>
      singleton
        .._onNavigationMethod = onNavigationMethod
        .._bannerIds = bannerIds
        .._interstitialIds = interstitialIds
        .._interRewardIds = interRewardIds
        .._loadingWidget = loadingWidget
        .._debugTestDeviceIds = debugTestDeviceIds
        .._debugGeography = debugGeography
        .._showDebugUI = debugShowDebugUI;

  // /// Returns a [GdprInitialPage].
  // static GdprInitialPage initialPage() => _singleton._gdprPage(false);

  // /// Returns a [GdprInitialPage] after reseting the GDPR consent values.
  // static GdprInitialPage initialPageReset() => _singleton._gdprPage(true);

  // /// Returns a [GdprUpdatePage].
  // static GdprUpdatePage updatePage() => _singleton._gdprUpdatePage();

  /// Returns a [GdprInitialPage].
  GdprInitialPage initialPage() => singleton._gdprPage(false);

  /// Returns a [GdprInitialPage] after reseting the GDPR consent values.
  GdprInitialPage initialPageReset() => singleton._gdprPage(true);

  /// Returns a [GdprUpdatePage].
  GdprUpdatePage updatePage() => singleton._gdprUpdatePage();

  /// Displays an GDPR initial dialog
  /// It will only display the dialog if not prior GDPR has been collected.
  GdprInitialPage _gdprPage(bool debugResetConsentForm) {
    return GdprInitialPage(
      () async => _initAdmob(),
      _onNavigationMethod,
      debugTestIdentifiers: _debugTestDeviceIds,
      showDebugUI: _showDebugUI,
      debugResetConsentForm: debugResetConsentForm,
      loadingWidget: _loadingWidget,
      debugGeography: _debugGeography,
    );
  }

  /// Displays an GDPR update consent form.
  /// It will always display the dialog.
  GdprUpdatePage _gdprUpdatePage() {
    return GdprUpdatePage(
      () async => _initAdmob(),
      _onNavigationMethod,
      debugTestIdentifiers: _debugTestDeviceIds,
      showDebugUI: _showDebugUI,
      loadingWidget: _loadingWidget,
    );
  }

  void _initAdmob() {
    AdService().initialize(
        bannerIds: _bannerIds,
        interstitialIds: _interstitialIds,
        interRewardIds: _interRewardIds,
        testDeviceIds: _debugTestDeviceIds);
  }
}
