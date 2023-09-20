import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gdprservice.dart';

/// Checks if a consent is necessary. Use this widget along these lines:
///
/// ```dart
/// [GdprUpdateScreen](
///   () async => await MobileAds.instance.initialize(),
///   () => Navigator.of(context).pushReplacement(
///        MaterialPageRoute(builder: (context) => YourNextWidget()),
///
///   /// Optional loading widget
///   loadingWidget: Scaffold(body:Center(child: Text('CONSENT! NOW!'))),
///  );
/// ```
///
/// - The first function will not get called in case of GDPR denial or error.
/// - The second function will always get called.
///
/// Debug parameters are supported:
///
/// ```dart
/// [GdprInitialScreen](
///   () async => await MobileAds.instance.initialize(),
///   () => Navigator.of(context).pushReplacement(
///        MaterialPageRoute(builder: (context) => YourNextWidget()),
/// ),
///
///   // Debug features are enabled for devices with these identifiers.
///   debugTestIdentifiers: ["741F74 ...... 149"],
///
///
///   // Will display a debug UI with the concrete error message, if any
///   // Automatic forwad navigation is off, user has to press a button instead
///   showDebugUI: kDebugMode,
/// );
/// ```
///
/// If on web:
///
/// 1. Executes user defined navigation method, as there are no ads for the web.
class GdprUpdateScreen extends StatefulWidget {
  final VoidCallback onConsentGivenInitMethod;
  final Function(BuildContext) onNavigationMethod;
  final Widget loadingWidget;
  final List<String>? debugTestIdentifiers;
  final bool showDebugUI;

  const GdprUpdateScreen(
    this.onConsentGivenInitMethod,
    this.onNavigationMethod, {
    this.loadingWidget = const Center(child: CircularProgressIndicator()),
    this.debugTestIdentifiers,
    this.showDebugUI = false,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  createState() => _GdprUpdateScreenState();
}

class _GdprUpdateScreenState extends State<GdprUpdateScreen> {
  GdprResult? gdprResult;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb) {
        widget.onNavigationMethod.call(context);
      } else {
        final GdprResult result = await GdprService.updateConsentForm(
            testIdentifiers: widget.debugTestIdentifiers);

        setState(() {
          gdprResult = result;
        });

        if (result.isSuccess()) {
          widget.onConsentGivenInitMethod.call();
        }

        if (widget.showDebugUI == false) {
          if (context.mounted) widget.onNavigationMethod.call(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // SHOW NO-DEBUG
    // -------------------------------------------------------------------------

    if (widget.showDebugUI == false) {
      return SafeArea(child: Scaffold(body: widget.loadingWidget));
    }

    // -------------------------------------------------------------------------
    // SHOW DEBUG
    // -------------------------------------------------------------------------

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(value: gdprResult != null ? 0 : null),
              if (gdprResult != null && widget.showDebugUI == true) ...[
                const SizedBox(height: 32),
                const Text('GDPR DEBUG MODE'),
                const SizedBox(height: 32),
                Text(
                    'Consent Status: ${gdprResult!.status != null ? gdprResult!.status!.name : '(value not set)'}'),
                const SizedBox(height: 32),
                if (gdprResult!.isSuccess()) ...[
                  const Text('GDPR processing with no errors'),
                  const SizedBox(height: 32),
                ],
                if (gdprResult!.isError()) ...[
                  const Text(
                    'Based on your testing,\nthe error below may be exptecd.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text('Error code: ${gdprResult!.errorCode}'),
                  Text(gdprResult!.errorMessage!),
                  const SizedBox(height: 32),
                ],
                ElevatedButton(
                    onPressed: () => widget.onNavigationMethod.call(context),
                    child: const Text('Navigate to next page')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
