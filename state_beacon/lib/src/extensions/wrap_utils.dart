part of '../base_beacon.dart';

extension ReadableBeaconWrapUtils<T> on ReadableBeacon<T> {
  /// Returns a [BufferedCountBeacon] that wraps this Beacon.
  /// See: [Beacon.bufferedCount] for more details.
  BufferedCountBeacon<T> buffer(
    int count, {
    String? debugLabel,
  }) {
    final beacon = Beacon.bufferedCount<T>(
      count,
      debugLabel: debugLabel,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: false,
      );

    if (!this._isEmpty) {
      beacon.add(peek());
    }

    return beacon;
  }

  /// Returns a [BufferedTimeBeacon] that wraps this Beacon.
  /// See: [Beacon.bufferedTime] for more details.
  BufferedTimeBeacon<T> bufferTime({
    required Duration duration,
    String? debugLabel,
  }) {
    final beacon = Beacon.bufferedTime<T>(
      duration: duration,
      debugLabel: debugLabel,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: false,
      );

    if (!this._isEmpty) {
      beacon.add(peek());
    }

    return beacon;
  }

  /// Returns a [DebouncedBeacon] that wraps this Beacon.
  /// See: [Beacon.debounced] for more details.
  DebouncedBeacon<T> debounce({
    bool startNow = true,
    required Duration duration,
    String? debugLabel,
  }) {
    if (startNow && !_isNullable && _isEmpty) {
      throw Exception(
        'startNow must be false if this beacon($debugLabel) is uninitialized',
      );
    }

    return Beacon.lazyDebounced(
      duration: duration,
      debugLabel: debugLabel,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: startNow,
      );
  }

  /// Returns a [ThrottledBeacon] that wraps this Beacon.
  /// See: [Beacon.throttled] for more details.
  ThrottledBeacon<T> throttle({
    bool startNow = true,
    required Duration duration,
    bool dropBlocked = true,
    String? debugLabel,
  }) {
    if (startNow && !_isNullable && _isEmpty) {
      throw Exception(
        'startNow must be false if this beacon($debugLabel) is uninitialized',
      );
    }

    return Beacon.lazyThrottled(
      duration: duration,
      dropBlocked: dropBlocked,
      debugLabel: debugLabel,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: startNow,
      );
  }

  /// Returns a [FilteredBeacon] that wraps this Beacon.
  /// See: [Beacon.filtered] for more details.
  FilteredBeacon<T> filter({
    bool startNow = true,
    bool Function(T?, T)? filter,
    String? debugLabel,
  }) {
    if (startNow && !_isNullable && _isEmpty) {
      throw Exception(
        'startNow must be false if this beacon($debugLabel) is uninitialized',
      );
    }

    return Beacon.lazyFiltered(
      filter: filter,
      debugLabel: debugLabel,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: startNow,
      );
  }
}
