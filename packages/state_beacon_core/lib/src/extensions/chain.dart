part of '../producer.dart';

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
  /// bufferedBeacon.add(20); //  equivalent to count.set(20, force: true);
  ///
  /// expect(count.value, equals(20));
  /// expect(bufferedBeacon.value, equals([]));
  /// expect(bufferedBeacon.currentBuffer.value, equals([20]));
  /// ```
  /// See: `Beacon.bufferedCount` for more details.
  BufferedCountBeacon<T> buffer(
    int count, {
    String? name,
    bool synchronous = true,
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

    _wrapAndDelegate(beacon, synchronous);

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
  BufferedTimeBeacon<T> bufferTime(
    Duration duration, {
    String? name,
    bool synchronous = true,
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

    _wrapAndDelegate(beacon, synchronous);

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
  DebouncedBeacon<T> debounce(
    Duration duration, {
    String? name,
    bool synchronous = true,
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

    _wrapAndDelegate(beacon, synchronous);

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
  /// throttledCount.value = 20; //  equivalent to count.set(20, force: true);
  ///
  /// expect(count.value, equals(20));
  /// expect(throttledCount.value, equals(10)); // this is 10 because the update was throttled
  /// ```
  /// See: `Beacon.throttled` for more details.
  ThrottledBeacon<T> throttle(
    Duration duration, {
    bool dropBlocked = true,
    bool synchronous = true,
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

    _wrapAndDelegate(beacon, synchronous);

    return beacon;
  }

  /// Returns a [FilteredBeacon] that wraps this Beacon.
  ///
  /// NB: All writes to the filtered beacon
  /// will be delegated to the wrapped beacon.
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
  FilteredBeacon<T> filter(
    bool Function(T?, T) filter, {
    String? name,
    bool lazyBypass = true,
    bool synchronous = true,
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

    _wrapAndDelegate(beacon, synchronous);

    return beacon;
  }

  /// Returns a [ReadableBeacon] that wraps a Beacon and tranforms its values.
  ///
  /// NB: All writes to the filtered beacon
  /// will be delegated to the wrapped beacon.
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
    bool synchronous = true,
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

    _wrapAndDelegate(beacon, synchronous);

    return beacon;
  }

  void _wrapAndDelegate<InputT, OutputT>(
    BeaconWrapper<InputT, OutputT> beacon,
    bool synchronous,
  ) {
    beacon.wrap(
      this,
      disposeTogether: true,
      startNow: !isEmpty || _isDerived,
      synchronous: synchronous,
    );

    // Example 1:
    // writable<int> -> filter<int> -> map<int,int> -> buffer
    // - when writable.filter():
    // 1. if writable is beaconwrapper<int,dynamic> : true
    // 2. if writable's delegate is WritableBeacon<int> : false
    // 3. if writable's delegate is null : true
    // 4. set writable to be filter's delegate

    // - when writable.filter().map():
    // 1. if filter is beaconwrapper<int,int> : true
    // 2. if filter's delegate is WritableBeacon<int> : true
    // 3. set writable to be map's delegate

    // - when writable.filter().map().buffer():
    // 1. if map is beaconwrapper<int,dynamic> : true
    // 2. if map's delegate is WritableBeacon<int> : true
    // 3. set writable to be buffer's delegate

    // Example 2:
    // writable<int> -> filter<int> -> map<int,string> -> buffer
    // - when writable.filter():
    // 1. if writable is beaconwrapper<int,int> : true
    // 2. if writable's delegate is WritableBeacon<int> : false
    // 3. if writable's delegate is null : true
    // 4. set writable to be filter's delegate

    // - when writable.filter().map():
    // 1. if filter is beaconwrapper<int,dynamic> : true
    // 2. if filter's delegate is WritableBeacon<int> : true
    // 3. set writable to be map's delegate

    // - when writable.filter().map().buffer():
    // 1. if map is beaconwrapper<String,dynamic> : false
    // 2. buffer takes a String so we can't delegate the writable<int> to it

    // stream -> map -> filter -> buffer
    // if this is a BeaconWrapper, then assign this's delegate to the new beacon
    if (this case final BeaconWrapper<InputT, dynamic> wrapped) {
      if (wrapped._delegate case final WritableBeacon<InputT> delegate) {
        beacon._delegate = delegate;
      } else if (wrapped._delegate == null) {
        beacon._delegate = wrapped;
      }
    }
  }
}
