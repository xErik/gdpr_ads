import 'package:flutter/material.dart';
import 'package:gdpr_ads/ads/adservice.dart';
import 'package:gdpr_ads/ads/src/countdowntimer.dart';

/// Template of a Rewarded Interstitial Dialog.
/// 1. It provides a countdown timer (default: 5 seconds).
/// 2. It asks for confirmation to show the Ad.
/// 3. It will call hooks an showing the Ad as well as on skipping the Ad.
///
/// Copy this class into your project and skin the included `AlertDialog` as needed.
///
/// Make sure to leave these hook calls intact:
/// `AdService().interstitialRewardedShowAdHook(adUnitId: widget.adUnitId);` and
/// `AdService().interstitialRewardedShowNoAdHook(adUnitId: widget.adUnitId);`
class RewardedInterstitialDialog extends StatefulWidget {
  final int countdownSeconds;
  final String? adUnitId;

  const RewardedInterstitialDialog(
      {this.countdownSeconds = 5, this.adUnitId, Key? key})
      : super(key: key);

  @override
  RewardedInterstitialDialogState createState() =>
      RewardedInterstitialDialogState();
}

class RewardedInterstitialDialogState
    extends State<RewardedInterstitialDialog> {
  late final CountdownTimer _countdownTimer;

  final _foreground = Colors.black;
  final _background = Colors.white;
  final _backgroundBadge = Colors.grey.shade600;

  RewardedInterstitialDialogState({Key? key});

  @override
  void initState() {
    _countdownTimer = CountdownTimer(widget.countdownSeconds);
    _countdownTimer.addListener(() {
      setState(() {}); // update the timer UI
      if (_countdownTimer.isComplete) {
        Navigator.pop(context);
        // Calls AdService, which will show the Ad and return the proper state.
        AdService().interstitialRewardedShowAdHook(adUnitId: widget.adUnitId);
      }
    });
    _countdownTimer.start();
    super.initState();
  }

  @override
  void dispose() {
    _countdownTimer.dispose();
    super.dispose();
  }

  /// Calls AdService, which will return the proper state.
  void _noThanksPressed() {
    AdService().interstitialRewardedShowNoAdHook(adUnitId: widget.adUnitId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------------------
    // EXAMPLE SKIN
    // ------------------------------------------------------------------------
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      backgroundColor: _background,
      iconColor: _foreground,
      titleTextStyle: TextStyle(color: _foreground),
      contentTextStyle: TextStyle(color: _foreground),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _badgeRight(),
          const SizedBox(height: 32),
          _message(),
          const SizedBox(height: 32),
          _noThanksTextButton(),
          //
          // An alternative no-thanks button:
          //
          // _notThanksOutlinedButton(),
        ],
      ),
    );
  }

  Widget _badgeRight() => Align(
      alignment: Alignment.centerRight,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: _backgroundBadge,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(width: 2, color: _background)),
          child: Text('Ad in ${_countdownTimer.timeLeft} seconds',
              style: TextStyle(color: _background))));

  Text _message() => const Text('Watch an Ad and earn a rewarded!',
      style: TextStyle(fontSize: 18), textAlign: TextAlign.center);

  Widget _noThanksTextButton() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: _foreground),
              onPressed: () => _noThanksPressed(),
              child: const Text('No, thanks')),
        ],
      );

  Widget _notThanksOutlinedButton() => Row(
        children: [
          Expanded(
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: _foreground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      side: BorderSide(width: 1, color: _foreground)),
                  onPressed: () => _noThanksPressed(),
                  child: const Text('No, thanks')))
        ],
      );
}
