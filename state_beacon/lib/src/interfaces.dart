import 'package:state_beacon/src/base_beacon.dart';

abstract class BeaconConsumer<S> {
  /// Wraps a `ReadableBeacon` and comsumes its values
  ///
  /// Supply a (`then`) function to customize how the emitted values are
  /// processed.
  ///
  /// NB: If no `then` function is provided, the value type of the target must be
  /// the same as the wrapper beacon.
  ///
  /// If the `disposeTogether` parameter is set to `true` (default), the wrapper beacon
  /// will be disposed when the target beacon is disposed and vice versa.
  ///
  /// Example:
  /// ```dart
  /// var bufferBeacon = Beacon.bufferedCount<int>(10);
  /// var count = Beacon.writable(5);
  ///
  /// // Wrap the bufferBeacon with the readableBeacon and provide a custom transformation.
  /// bufferBeacon.wrap(count, then: (beacon, value) {
  ///   // Custom transformation: Add the value twice to the buffer.
  ///   beacon.add(value);
  ///   beacon.add(value);
  /// });
  ///
  /// print(bufferBeacon.buffer); // Outputs: [5, 5]
  ///
  /// count.value = 10;
  ///
  /// print(bufferBeacon.buffer); // Outputs: [5, 5, 10, 10]
  /// ```
  S wrap<U>(
    ReadableBeacon<U> target, {
    void Function(S, U)? then,
    bool startNow = true,
    bool disposeTogether = false,
  });

  void clearWrapped();
}

// abstract class StreamConsumer<T> {
//   void ingest<U>(
//     Stream<U> target, {
//     Function(T, U)? then,
//   });
// }
