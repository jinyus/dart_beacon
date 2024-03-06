part of '../producer.dart';

/// See: Beacon.stream()
class StreamBeacon<T> extends AsyncBeacon<T> {
  /// @macro stream
  StreamBeacon(
    super._compute, {
    required super.shouldSleep,
    super.cancelOnError = false,
    super.name,
    super.manualStart,
  });

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_sub?.cancel());
    _sub = null;
  }

  /// Pauses the internal stream subscription
  void pause([Future<void>? resumeSignal]) {
    _sub?.pause(resumeSignal);
  }

  /// Resumes the internal stream subscription
  /// if it was paused.
  void resume() {
    _sub?.resume();
  }

  /// Exposes this as a [Future] that can be awaited in a future beacon.
  /// This will trigger a re-run of the derived beacon when its state changes.
  Future<T> toFuture() {
    if (_completer == null) {
      // first time
      final completer = Completer<T>();
      _completer = Beacon.writable(completer, name: "$name's future");

      if (peek() case final AsyncData<T> data) {
        completer.complete(data.value);
      } else if (peek() case final AsyncError<T> error) {
        completer.completeError(error.error, error.stackTrace);
      }
    }

    return _completer!.value.future;
  }
}
