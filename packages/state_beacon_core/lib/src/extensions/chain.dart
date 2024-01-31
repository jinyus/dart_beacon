part of '../base_beacon.dart';

// ignore: public_member_api_docs
extension ReadableBeaconWrapUtils<T> on ReadableBeacon<T> {
  /// Returns a [BufferedCountBeacon] that wraps this Beacon.
  ///
  /// NB: All writes to the buffered beacon
  /// will be delegated to the wrapped beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final bufferedBeacon = count.buffer(2);
  ///
  /// bufferedBeacon.add(20); //  equivalent to count.value = 20;
  ///
  /// expect(count.value, equals(20));
  /// expect(bufferedBeacon.value, equals([]));
  /// expect(bufferedBeacon.currentBuffer.value, equals([20]));
  /// ```
  /// See: `Beacon.bufferedCount` for more details.
  BufferedCountBeacon<T> buffer(
    int count, {
    String? name,
  }) {
    assert(
      this is! BufferedBaseBeacon,
      '''
Chaining of buffered beacons is not supported!
Buffered beacons has to be the last in the chain.

Good: someBeacon.filter().buffer(10);

Bad: someBeacon.buffer(10).filter();

If you absolutely need this functionality, it has to be done manually with "wrap".
eg:
final beacon = Beacon.bufferedCount<T>(count).wrap(someBufferedBeacon)
''',
    );

    final beacon = Beacon.bufferedCount<T>(
      count,
      name: name,
    );

    _wrapAndDelegate(beacon);

    return beacon;
  }

  /// Returns a [BufferedTimeBeacon] that wraps this Beacon.
  ///
  /// NB: All writes to the buffered beacon
  /// will be delegated to the wrapped beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final bufferedBeacon = count.bufferTime(duration: k10ms);
  ///
  /// bufferedBeacon.add(20); //  equivalent to count.value = 20;
  ///
  /// expect(count.value, equals(20));
  /// expect(bufferedBeacon.value, equals([]));
  /// expect(bufferedBeacon.currentBuffer.value, equals([20]));
  ///
  /// await Future.delayed(k10ms);
  ///
  /// expect(bufferedBeacon.value, equals([20]));
  /// ```
  /// See: `Beacon.bufferedTime` for more details.
  BufferedTimeBeacon<T> bufferTime({
    required Duration duration,
    String? name,
  }) {
    assert(
      this is! BufferedBaseBeacon,
      '''
Chaining of buffered beacons is not supported!
Buffered beacons has to be the last in the chain.

Good: someBeacon.filter().buffer(10);

Bad: someBeacon.buffer(10).filter();

If you absolutely need this functionality, it has to be done manually with .wrap.
eg:
final beacon = Beacon.bufferedCount<T>(count).wrap(someBufferedBeacon)
''',
    );

    final beacon = Beacon.bufferedTime<T>(
      duration: duration,
      name: name,
    );

    _wrapAndDelegate(beacon);

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
  /// debouncedCount.value = 20; //  equivalent to count.value = 20;
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
    String? name,
  }) {
    assert(
      this is! BufferedBaseBeacon,
      '''
Chaining of buffered beacons is not supported!
Buffered beacons has to be the last in the chain.

Good: someBeacon.filter().buffer(10);

Bad: someBeacon.buffer(10).filter();

If you absolutely need this functionality, it has to be done manually with .wrap.
eg:
final beacon = Beacon.debounced<T>(0).wrap(someBufferedBeacon)
''',
    );

    final beacon = Beacon.lazyDebounced<T>(
      duration: duration,
      name: name,
    );

    _wrapAndDelegate(beacon);

    return beacon;
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
  /// throttledCount.value = 20; //  equivalent to count.value = 20;
  ///
  /// expect(count.value, equals(20));
  /// expect(throttledCount.value, equals(10)); // this is 10 because the update was throttled
  /// ```
  /// See: `Beacon.throttled` for more details.
  ThrottledBeacon<T> throttle({
    required Duration duration,
    bool dropBlocked = true,
    String? name,
  }) {
    assert(
      this is! BufferedBaseBeacon,
      '''
Chaining of buffered beacons is not supported!
Buffered beacons has to be the last in the chain.

Good: someBeacon.filter().buffer(10);

Bad: someBeacon.buffer(10).filter();

If you absolutely need this functionality, it has to be done manually with .wrap.
eg:
final beacon = Beacon.throttled<T>(0).wrap(someBufferedBeacon)
''',
    );

    final beacon = Beacon.lazyThrottled<T>(
      duration: duration,
      dropBlocked: dropBlocked,
      name: name,
    );

    _wrapAndDelegate(beacon);

    return beacon;
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
  /// filteredCount.value = 20; //  equivalent to count.value = 20;
  ///
  /// expect(count.value, equals(20));
  /// expect(filteredCount.value, equals(20));
  /// ```
  /// See: `Beacon.filtered` for more details.
  FilteredBeacon<T> filter({
    bool Function(T?, T)? filter,
    String? name,
  }) {
    assert(
      this is! BufferedBaseBeacon,
      '''
Chaining of buffered beacons is not supported!
Buffered beacons has to be the last in the chain.

Good: someBeacon.filter().buffer(10);

Bad: someBeacon.buffer(10).filter();

If you absolutely need this functionality, it has to be done manually with .wrap.
eg:
final beacon = Beacon.filtered<T>(0).wrap(someBufferedBeacon)
''',
    );

    final beacon = Beacon.lazyFiltered<T>(
      filter: filter,
      name: name,
    );

    _wrapAndDelegate(beacon);

    return beacon;
  }

  void _wrapAndDelegate<InputT, OutputT>(
    BeaconConsumer<InputT, OutputT> beacon,
  ) {
    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty,
    );

    if (this is WritableBeacon<InputT>) {
      beacon._delegate = this as WritableBeacon<InputT>;
    }
  }
}
