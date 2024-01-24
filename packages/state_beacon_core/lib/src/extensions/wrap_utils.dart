part of '../base_beacon.dart';

// ignore: public_member_api_docs
extension ReadableBeaconWrapUtils<T> on ReadableBeacon<T> {
  /// Returns a [BufferedCountBeacon] that wraps this Beacon.
  /// See: [Beacon.bufferedCount] for more details.
  BufferedCountBeacon<T> buffer(
    int count, {
    String? name,
  }) {
    final beacon = Beacon.bufferedCount<T>(
      count,
      name: name,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: false,
      );

    if (!isEmpty) {
      beacon.add(peek());
    }

    return beacon;
  }

  /// Returns a [BufferedTimeBeacon] that wraps this Beacon.
  /// See: [Beacon.bufferedTime] for more details.
  BufferedTimeBeacon<T> bufferTime({
    required Duration duration,
    String? name,
  }) {
    final beacon = Beacon.bufferedTime<T>(
      duration: duration,
      name: name,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: false,
      );

    if (!isEmpty) {
      beacon.add(peek());
    }

    return beacon;
  }

  /// Returns a [DebouncedBeacon] that wraps this Beacon.
  /// See: [Beacon.debounced] for more details.
  DebouncedBeacon<T> debounce({
    required Duration duration,
    bool startNow = true,
    String? name,
  }) {
    if (startNow && !_isNullable && _isEmpty) {
      throw Exception(
        'startNow must be false if this beacon($name) is uninitialized',
      );
    }

    return Beacon.lazyDebounced(
      duration: duration,
      name: name,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: startNow,
      );
  }

  /// Returns a [ThrottledBeacon] that wraps this Beacon.
  /// See: [Beacon.throttled] for more details.
  ThrottledBeacon<T> throttle({
    required Duration duration,
    bool startNow = true,
    bool dropBlocked = true,
    String? name,
  }) {
    if (startNow && !_isNullable && _isEmpty) {
      throw Exception(
        'startNow must be false if this beacon($name) is uninitialized',
      );
    }

    return Beacon.lazyThrottled(
      duration: duration,
      dropBlocked: dropBlocked,
      name: name,
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
    String? name,
  }) {
    if (startNow && !_isNullable && _isEmpty) {
      throw Exception(
        'startNow must be false if this beacon($name) is uninitialized',
      );
    }

    return Beacon.lazyFiltered(
      filter: filter,
      name: name,
    )..wrap(
        this,
        disposeTogether: true,
        startNow: startNow,
      );
  }
}
