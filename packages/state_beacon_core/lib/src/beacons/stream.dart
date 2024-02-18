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
}
