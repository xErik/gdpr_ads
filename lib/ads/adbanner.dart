import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'adservice.dart';
import 'responsebanner.dart';

/// Shows an AddBanner.
///
/// Allows to define a widget placed beneath it in case the ad is loaded and shown.
///
/// The [backgroundColor] will be behind the ad itself and behind
/// [widgetBelowIfAddIsShown] and [widgetAboveIfAddIsShown].
///
/// in [kDebugMode] it will display debug information until the add is loaded.
class AdBanner extends StatelessWidget {
  final Widget widgetBelowIfAddIsShown;
  final Widget widgetAboveIfAddIsShown;
  final Color backgroundColor;
  late final Future<ResponseBanner> future;

  AdBanner(
      {String? adUnitId,
      this.widgetAboveIfAddIsShown = const SizedBox.shrink(),
      this.widgetBelowIfAddIsShown = const SizedBox.shrink(),
      this.backgroundColor = Colors.white,
      Key? key})
      : super(key: key) {
    future = AdService().getBanner(adUnitId: adUnitId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResponseBanner>(
      future: future,
      builder: ((context, snapshot) {
        if (snapshot.hasData == false) {
          if (kDebugMode) return _debugLabel('Loading');
          return const SizedBox.shrink();
        } else if (snapshot.data!.hasAd() == false) {
          if (kDebugMode) {
            return _debugLabel(snapshot.data!.prettyError());
          }
          return const SizedBox.shrink();
        }

        return Container(
          color: backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetBelowIfAddIsShown,
              Container(
                width: snapshot.data!.ad!.size.width.toDouble(),
                height: 72.0,
                alignment: Alignment.center,
                child: AdWidget(ad: snapshot.data!.ad!),
              ),
              widgetBelowIfAddIsShown,
            ],
          ),
        );
      }),
    );
  }

  _debugLabel(String label) {
    return Container(
        color: Colors.yellow.shade100,
        child: Text('DEBUG: $label', textAlign: TextAlign.center));
  }
}
