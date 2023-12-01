part of '../base_beacon.dart';

class WritableBeacon<T> extends ReadableBeacon<T> {
  WritableBeacon(T super.initialValue);

  set value(T newValue) {
    _setValue(newValue);
  }

  /// Wraps an existing `ReadableBeacon` without transforming its value.
  /// The value from the `originalBeacon` is passed directly to the `wrapperBeacon`.
  /// eg: Wrapping a StreamBeacon with a ThrottledBeacon to throttle the stream's emitted values.
  ///
  /// Example:
  /// ```dart
  /// var originalBeacon = Beacon.readable(10);
  /// var wrapperBeacon = Beacon.writable(0);
  ///
  /// wrapperBeacon.wrap(originalBeacon);
  /// print(wrapperBeacon.value); // Outputs: 10
  /// ```
  void wrap(ReadableBeacon<T> originalBeacon) {
    effect(() {
      value = originalBeacon.value;
    });
  }

  /// Wraps an existing `ReadableBeacon` like [wrap], but allows transformation of its value.
  /// The value from the `originalBeacon` is transformed by the `transform` function before being passed to the `wrapperBeacon`.
  ///
  /// Example:
  /// ```dart
  /// var originalBeacon = Beacon.readable(10);
  /// var wrapperBeacon = Beacon.writable("");
  ///
  /// wrapperBeacon.wrapWithTransform(
  ///   originalBeacon,
  ///   transform: (value) => "Value is $value"
  /// );
  /// print(wrapperBeacon.value); // Outputs: "Value is 10"
  /// ```
  void wrapWithTransform<U>(
    ReadableBeacon<U> originalBeacon, {
    required T Function(U) transform,
  }) {
    effect(() {
      value = transform(originalBeacon.value);
    });
  }
}
