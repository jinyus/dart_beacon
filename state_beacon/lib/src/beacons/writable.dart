part of '../base_beacon.dart';

class WritableBeacon<T> extends ReadableBeacon<T> {
  WritableBeacon(T super.initialValue);

  set value(T newValue) {
    set(newValue);
  }

  void set(T newValue, {bool force = false}) {
    _setValue(newValue, force: force);
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
  VoidCallback wrap(ReadableBeacon<T> originalBeacon,
      {bool runImmediately = true}) {
    return originalBeacon.subscribe(
      (v) {
        value = v;
      },
      runImmediately: runImmediately,
    );
  }

  /// Wraps an existing `ReadableBeacon` and allows you to perform a custom transformation
  /// on its value before updating the value of the current `wrapperBeacon`. The transformation
  /// is defined by the provided `then` function, which takes the current `wrapperBeacon`
  /// and the value from the `originalBeacon` as its arguments.
  ///
  /// Example:
  /// ```dart
  /// var originalBeacon = Beacon.readable(10);
  /// var wrapperBeacon = Beacon.writable(0);
  ///
  /// wrapperBeacon.wrapThen(originalBeacon, then: (wrapper, originalValue) {
  ///   // Perform a custom transformation, e.g., doubling the value
  ///   var transformedValue = originalValue * 2;
  ///
  ///   // Update the value of the wrapperBeacon with the transformed value
  ///   wrapper.value = transformedValue;
  /// });
  ///
  /// print(wrapperBeacon.value); // Outputs: 20
  /// ```
  VoidCallback wrapThen<U>(
    ReadableBeacon<U> originalBeacon, {
    required Function(ReadableBeacon<T>, U) then,
    bool runImmediately = true,
  }) {
    return originalBeacon.subscribe(
      (v) {
        then(this, v);
      },
      runImmediately: runImmediately,
    );
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
  VoidCallback wrapWithTransform<U>(
    ReadableBeacon<U> originalBeacon, {
    required T Function(U) transform,
    bool runImmediately = true,
  }) {
    return originalBeacon.subscribe(
      (v) {
        value = transform(v);
      },
      runImmediately: runImmediately,
    );
  }
}
