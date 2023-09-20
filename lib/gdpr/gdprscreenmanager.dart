import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/gdpr/gdprservice.dart';
import 'package:gdpr_ads/gdpr/gdprupdatescreen.dart';

import 'gdprinitialscreen.dart';

/// This class is a convenience singleton to make [GdprInitialScreen] and
/// [GdprUpdateScreen] reusable with the same configuration.
///
/// The initial consent form will check if a consent is necessary first and
/// immediately return without showing a consent form if not. This form is meant to
/// get the initial consent of a user.
///
/// The update consent form will ALWAYS show its consent form. This form is meant to
/// change a user's consent.
///
/// Usage:
///
/// ```dart
/// GdprScreenManager( ... params ...);
///
/// GdprScreenManager( ... params ...).initialGdprScreen();
///
/// Scaffold(body:
///   GdprScreenManager.getInitialGdprScreen());
///
/// Scaffold(body:
///   GdprScreenManager.getInitialResetGdprScreen());
///
/// Scaffold(body:
///   GdprScreenManager.getUpdateGdprScreen());
/// ```
class GdprScreenManager {
  late Function(BuildContext) _onNavigationMethod;
  late List<String> _bannerIds;
  late List<String> _interstitialIds;
  late List<String> _interRewardIds;
  late List<String> _debugTestDeviceIds;
  late Widget _loadingWidget;
  late GdprDebugGeography _debugGeography;
  late bool _showDebugUI;

  GdprScreenManager._internal();
  static final GdprScreenManager _singleton = GdprScreenManager._internal();

  /// Initializes this singleton
  factory GdprScreenManager(
    final Function(BuildContext) onNavigationMethod, {
    final List<String> bannerIds = const [],
    final List<String> interstitialIds = const [],
    final List<String> interRewardIds = const [],
    final List<String> debugTestDeviceIds = const [],
    final Widget loadingWidget =
        const Center(child: CircularProgressIndicator()),
    final GdprDebugGeography debugGeography = GdprDebugGeography.disabled,
    final bool debugShowDebugUI = false,
  }) =>
      _singleton
        .._onNavigationMethod = onNavigationMethod
        .._bannerIds = bannerIds
        .._interstitialIds = interstitialIds
        .._interRewardIds = interRewardIds
        .._loadingWidget = loadingWidget
        .._debugTestDeviceIds = debugTestDeviceIds
        .._debugGeography = debugGeography
        .._showDebugUI = debugShowDebugUI;

  /// Returns a [GdprInitialScreen].
  static GdprInitialScreen initialGdprScreen() => _singleton._gdprScreen(false);

  /// Returns a [GdprInitialScreen] after reseting the GDPR consent values.
  static GdprInitialScreen initialResetGdprScreen() =>
      _singleton._gdprScreen(true);

  /// Returns a [GdprUpdateScreen].
  static GdprUpdateScreen updateGdprScreen() => _singleton._gdprUpdateScreen();

  /// Returns a [GdprInitialScreen].
  /// Useful for calling after instantiating this singleton class.
  GdprInitialScreen getInitialGdprScreen() => initialGdprScreen();

  /// Displays an GDPR initial dialog
  /// It will only display the dialog if not prior GDPR has been collected.
  GdprInitialScreen _gdprScreen(bool debugResetConsentForm) {
    return GdprInitialScreen(
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
  GdprUpdateScreen _gdprUpdateScreen() {
    return GdprUpdateScreen(
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
