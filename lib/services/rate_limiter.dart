import 'dart:async';

class RateLimiter {
  static const int maxRequests = 10;
  static const Duration resetDuration = Duration(seconds: 1);
  int _requestCount = 0;
  Timer? _timer;

  Future<void> execute(Function apiCall) async {
    if (_requestCount >= maxRequests) {
      await Future.delayed(resetDuration);
      _requestCount = 0;
    }
    _requestCount++;
    await apiCall();

    _timer ??= Timer(resetDuration, () {
      _requestCount = 0;
      _timer = null;
    });
  }
}
