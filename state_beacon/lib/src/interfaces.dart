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
    Function(S, U)? then,
    bool startNow = true,
  });
}

// abstract class StreamConsumer<T> {
//   void ingest<U>(
//     Stream<U> target, {
//     Function(T, U)? then,
//   });
// }
