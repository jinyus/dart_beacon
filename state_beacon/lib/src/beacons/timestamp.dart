part of '../base_beacon.dart';

typedef TimestampValue<T> = ({T value, DateTime timestamp});

class TimestampBeacon<T> extends BaseBeacon<TimestampValue<T>> {
  TimestampBeacon([T? initialValue])
      : super(initialValue != null || null is T
            ? (value: initialValue as T, timestamp: DateTime.now())
            : null);

  void set(T newValue) {
    _setValue((value: newValue, timestamp: DateTime.now()));
  }
}
