part of '../base_beacon.dart';

// ignore: public_member_api_docs
extension ReadableBeaconWrapUtils<T> on ReadableBeacon<T> {
  /// Returns a [BufferedCountBeacon] that wraps this Beacon.
  /// See: `Beacon.bufferedCount` for more details.
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
  /// See: `Beacon.bufferedTime` for more details.
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
  ///
  /// NB: All writes to the debounced beacon
  /// will be delegated to the wrapped beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final debouncedCount = count.debounce(duration: k10ms);
  ///
  /// debouncedCount.value = 20;
  ///
  /// expect(count.value, equals(20));
  ///
  /// expect(debouncedCount.value, equals(10)); // this is 10 because the update is being debounced
  ///
  /// await Future.delayed(k10ms);
  ///
  /// expect(debouncedCount.value, equals(20)); // this is 20 because the update was debounced
  /// ```
  ///
  /// See: `Beacon.debounced` for more details.
  DebouncedBeacon<T> debounce({
    required Duration duration,
    bool startNow = true,
    String? name,
  }) {
    final beacon = Beacon.lazyDebounced<T>(
      duration: duration,
      name: name,
    );

    if (this case final WritableBeacon<T> w) {
      beacon._delegate = w;
    }

    return beacon
      ..wrap(
        this,
        disposeTogether: true,
        startNow: !isEmpty,
      );
  }

  /// Returns a [ThrottledBeacon] that wraps this Beacon.
  ///
  /// NB: All writes to the throttled beacon
  /// will be delegated to the wrapped beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final throttledCount = count.throttle(duration: k10ms);
  ///
  /// throttledCount.value = 20;
  ///
  /// expect(count.value, equals(20));
  /// expect(throttledCount.value, equals(10)); // this is 10 because the update was throttled
  /// ```
  /// See: `Beacon.throttled` for more details.
  ThrottledBeacon<T> throttle({
    required Duration duration,
    bool startNow = true,
    bool dropBlocked = true,
    String? name,
  }) {
    final beacon = Beacon.lazyThrottled<T>(
      duration: duration,
      dropBlocked: dropBlocked,
      name: name,
    );

    if (this case final WritableBeacon<T> w) {
      beacon._delegate = w;
    }

    return beacon
      ..wrap(
        this,
        disposeTogether: true,
        startNow: !isEmpty,
      );
  }

  /// Returns a [FilteredBeacon] that wraps this Beacon.
  ///
  /// NB: All writes to the filtered beacon
  /// will be delegated to the wrapped beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final filteredCount = count.filter(filter: (prev, next) => next > 10);
  ///
  /// filteredCount.value = 20;
  ///
  /// expect(count.value, equals(20));
  /// expect(filteredCount.value, equals(20));
  /// ```
  /// See: `Beacon.filtered` for more details.
  FilteredBeacon<T> filter({
    bool startNow = true,
    bool Function(T?, T)? filter,
    String? name,
  }) {
    final beacon = Beacon.lazyFiltered<T>(
      filter: filter,
      name: name,
    );

    if (this case final WritableBeacon<T> w) {
      beacon._delegate = w;
    }

    return beacon
      ..wrap(
        this,
        disposeTogether: true,
        startNow: !isEmpty,
      );
  }
}
