import 'dart:async';

import 'package:flutter/material.dart';

/// Countdown state
enum CountdownState {
  notStarted,
  active,
  ended,
}

/// A simple class that keeps track of a decrementing timer.
class CountdownTimer extends ChangeNotifier {
  late final Timer _timer;
  final int _countdownTime;
  late int timeLeft = _countdownTime;
  var _countdownState = CountdownState.notStarted;
  bool get isComplete => _countdownState == CountdownState.ended;

  CountdownTimer(this._countdownTime);

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft--;

      if (timeLeft == 0) {
        _countdownState = CountdownState.ended;
        timer.cancel();
      }

      notifyListeners();
    });
    _countdownState = CountdownState.active;

    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
