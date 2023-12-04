part of '../base_beacon.dart';

class FutureBeacon<T> extends ReadableBeacon<AsyncValue<T>> {
  var _executionID = 0;

  FutureBeacon(this._operation) : super(AsyncLoading()) {
    _init();
  }

  final Future<T> Function() _operation;

  /// Resets the signal by calling the [Future] again
  @override
  void reset() {
    _executionID++;
    _init();
  }

  Future<void> _init() async {
    final currentTracker = ++_executionID;
    if (peek() is! AsyncLoading) {
      _setValue(AsyncLoading());
    }

    void updateOrIgnore(AsyncValue<T> value) {
      // if currentTacker != _tracker, another call to
      // init has been made so we should ignore this result
      if (currentTracker == _executionID) {
        _setValue(value);
      }
    }

    try {
      final result = await _operation();
      return updateOrIgnore(AsyncData(result));
    } catch (e, s) {
      return updateOrIgnore(AsyncError(e, s));
    }
  }
}
