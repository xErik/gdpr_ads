import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'gdprservice.dart';

/// Checks if a consent is necessary. Use this widget along these lines:
///
/// ```dart
/// [GdprInitialScreen](
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
///   // Debug geography for testing geography.
///   debugGeography: GdprHelperDebugGeography.insideEea,
///
///   // Will reset the consent form before showing it
///   debugResetConsentForm: true,
///
///   // Will display a debug UI with the concrete error message, if any
///   // Automatic forwad navigation is off, user has to press a button instead
///   showDebugUI: kDebugMode,
/// );
/// ```
///
///
/// ## If consent is necessary
///
/// Displays consent form.
///
/// If consent is given:
/// 1. Executes user defined init method.
/// 2. Executes user defined navigation method.
///
/// If consent is NOT given:
/// 1. Executes user defined navigation method.
///
/// ## If consent is NOT necessary
///
/// 1. Executes user defined navigation method.
///
/// ## If on web:
///
/// 1. Executes user defined navigation method, as there are no ads for the web.
class GdprInitialScreen extends StatefulWidget {
  final AsyncCallback onConsentGivenInitMethod;
  final Function(BuildContext) onNavigationMethod;
  final Widget loadingWidget;
  final GdprDebugGeography debugGeography;
  final List<String>? debugTestIdentifiers;
  final bool debugResetConsentForm;
  final bool showDebugUI;

  const GdprInitialScreen(
    this.onConsentGivenInitMethod,
    this.onNavigationMethod, {
    this.loadingWidget = const Center(child: CircularProgressIndicator()),
    super.key,
    this.debugGeography = GdprDebugGeography.disabled,
    this.debugTestIdentifiers,
    this.debugResetConsentForm = false,
    this.showDebugUI = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  createState() => _GdprInitialScreenState();
}

class _GdprInitialScreenState extends State<GdprInitialScreen> {
  GdprResult? gdprResult;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb) {
        widget.onNavigationMethod.call(context);
      } else {
        if (widget.debugResetConsentForm) {
          await GdprService.resetConsentForm();
        }

        final GdprResult result = await GdprService.requestConsentForm(
          debugGeography: widget.debugGeography,
          testIdentifiers: widget.debugTestIdentifiers,
        );

        setState(() {
          gdprResult = result;
        });

        if (result.isSuccess()) {
          await widget.onConsentGivenInitMethod.call();
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
