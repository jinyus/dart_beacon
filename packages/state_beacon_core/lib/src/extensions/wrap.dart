part of '../producer.dart';

// ignore_for_file: lines_longer_than_80_chars

// ignore: public_member_api_docs
extension WritableWrap<T, U> on BeaconWrapper<T, U> {
  /// Wraps a `ReadableBeacon` and comsume its values
  ///
  /// Supply a (`then`) function to customize how the emitted values are
  /// processed.
  ///
  /// NB: If no `then` function is provided, the value type of the target must be
  /// the same as the wrapper beacon.
  ///
  /// If the `disposeTogether` parameter is set to `true` (default: false), the wrapper beacon
  /// will be disposed when the target beacon is disposed and vice versa.
  ///
  /// Example:
  /// ```dart
  /// var bufferBeacon = Beacon.bufferedCount<String>(10);
  /// var count = Beacon.writable(5);
  ///
  /// // Wrap the bufferBeacon with the readableBeacon and provide a custom transformation.
  /// bufferBeacon.wrap(count, then: (value) {
  ///   // Custom transformation: Convert the value to a string and add it to the buffer.
  ///   bufferBeacon.add(value.toString());
  /// });
  ///
  /// print(bufferBeacon.buffer); // Outputs: ['5']
  ///
  /// count.value = 10;
  ///
  /// print(bufferBeacon.buffer); // Outputs: ['5', '10']
  /// ```
  void wrap<V>(
    ReadableBeacon<V> target, {
    void Function(V)? then,
    bool disposeTogether = false,
    bool startNow = true,
  }) {
    if (_wrapped.containsKey(target.hashCode)) return;

    if (then == null && T != V) {
      throw WrapTargetWrongTypeException(name, target.name);
    }

    // if (startNow && target.isEmpty) {
    //   throw Exception(
    //     'target($target) is uninitialized so startNow must be false',
    //   );
    // }

    final fn = then ?? ((val) => _onNewValueFromWrapped(val as T));

    final unsub = target.subscribe(
      fn,
      startNow: startNow,
    );

    _wrapped[target.hashCode] = unsub;

    if (disposeTogether) {
      var isDisposing = false;

      target.onDispose(() {
        if (isDisposing) return;
        isDisposing = true;
        dispose();
      });

      onDispose(() {
        if (isDisposing || target._guarded) return;
        isDisposing = true;
        target.dispose();
      });
    }

    return;
  }

  /// Injest a `Stream` and add all values emitted from it to this beacon
  ///
  /// example:
  /// ```dart
  /// var beacon = Beacon.writable(0);
  /// var myStream = Stream.fromIterable([1, 2, 3]);
  ///
  /// beacon.injest(myStream);
  /// ```
  void ingest(
    Stream<T> source, {
    void Function(T)? then,
    T? initialValue,
  }) {
    final internalBeacon = RawStreamBeacon<T>(
      () => source,
      isLazy: true,
      initialValue: initialValue,
      shouldSleep: true,
    );

    wrap(
      internalBeacon,
      then: then,
      startNow: false,
    );

    internalBeacon.onDispose(() {
      _wrapped.remove(internalBeacon.hashCode);
      // don't dispose parent beacon because
      // internal is disposed when the stream ends
    });

    onDispose(internalBeacon.dispose);
  }
}
