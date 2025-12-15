part of '../producer.dart';

// ignore: public_member_api_docs
extension ReadableBeaconWrapUtils<T> on ReadableBeacon<T> {
  /// Returns a [BufferedCountBeacon] that wraps this Beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final bufferedBeacon = count.buffer(2);
  ///
  /// bufferedBeacon.add(20); //  equivalent to count.set(20, force: true);
  ///
  /// expect(count.value, equals(20));
  /// expect(bufferedBeacon.value, equals([]));
  /// expect(bufferedBeacon.currentBuffer.value, equals([20]));
  /// ```
  /// See: `Beacon.bufferedCount` for more details.
  ReadableBufferedBeacon<T> buffer(
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

    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
    );

    return beacon;
  }

  /// Returns a [BufferedTimeBeacon] that wraps this Beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final bufferedBeacon = count.bufferTime(duration: k10ms);
  ///
  /// bufferedBeacon.add(20); //  equivalent to count.set(20, force: true);
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
  ReadableBufferedBeacon<T> bufferTime(
    Duration duration, {
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

    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
    );

    return beacon;
  }

  /// Returns a [DebouncedBeacon] that wraps this Beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final debouncedCount = count.debounce(duration: k10ms);
  ///
  /// debouncedCount.value = 20; //  equivalent to count.set(20, force: true);
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
  ReadableBeacon<T> debounce(
    Duration duration, {
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

    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
    );

    return beacon;
  }

  /// Returns a [ThrottledBeacon] that wraps this Beacon.
  ///
  /// ```
  /// final count = Beacon.writable(10);
  /// final throttledCount = count.throttle(duration: k10ms);
  ///
  /// throttledCount.value = 20; //  equivalent to count.set(20, force: true);
  ///
  /// expect(count.value, equals(20));
  /// expect(throttledCount.value, equals(10)); // this is 10 because the update was throttled
  /// ```
  /// See: `Beacon.throttled` for more details.
  ReableThrottledBeacon<T> throttle(
    Duration duration, {
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

    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
    );

    return beacon;
  }

  /// Returns a [FilteredBeacon] that wraps this Beacon.
  ///
  /// ```dart
  /// final count = Beacon.writable(10);
  /// final filteredCount = count.filter((prev, next) => next > 10);
  ///
  /// filteredCount.value = 20; //  equivalent to count.set(20, force: true);
  ///
  /// expect(count.value, equals(20));
  /// expect(filteredCount.value, equals(20));
  /// ```
  ///
  /// The first value will not be filtered if the source is lazy.
  /// You can override this by setting lazyBypass to false.
  ///
  /// See: `Beacon.filtered` for more details.
  ReadableFilteredBeacon<T> filter(
    bool Function(T?, T) filter, {
    String? name,
    bool lazyBypass = true,
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
      lazyBypass: lazyBypass,
    );

    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
    );

    return beacon;
  }

  /// Returns a [ReadableBeacon] that wraps a Beacon and tranforms its values.
  ///
  /// ```dart
  /// final count = Beacon.writable(10);
  /// final mapped = count.map((value) => value * 2);
  ///
  /// expect(mapped.value, 20);
  ///
  /// count.value = 20;
  ///
  /// expect(count.value, 20);
  /// expect(mapped.value, 40);
  /// ```
  ReadableBeacon<O> map<O>(
    MapFilter<T, O> mapFN, {
    String? name,
  }) {
    assert(
      this is! BufferedBaseBeacon,
      '''
Chaining of buffered beacons is not supported!
Buffered beacons has to be the last in the chain.

Good: someBeacon.map().buffer(10);

Bad: someBeacon.buffer(10).map();
''',
    );

    final beacon = _MappedBeacon(mapFN, name: name);

    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
    );

    return beacon;
  }
}
