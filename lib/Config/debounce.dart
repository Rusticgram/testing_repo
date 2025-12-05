import 'dart:async';

class Debounce {
  final int seconds;

  Debounce({this.seconds = 2});

  Timer? _timer;

  void run(Future<void> action) async {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(seconds: seconds), () => action);
  }
}
