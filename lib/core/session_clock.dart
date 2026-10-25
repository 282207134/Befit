import 'dart:async';

import 'package:flutter/foundation.dart';

/// Stopwatch measures elapsed time; Timer only asks the UI to refresh.
class SessionClock extends ChangeNotifier {
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  bool get running => _watch.isRunning;
  int get seconds => _watch.elapsed.inSeconds;
  void start() {
    if (running) return;
    _watch.start();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => notifyListeners(),
    );
    notifyListeners();
  }

  void pause() {
    _watch.stop();
    _ticker?.cancel();
    notifyListeners();
  }

  void reset() {
    pause();
    _watch.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _watch.stop();
    super.dispose();
  }
}
