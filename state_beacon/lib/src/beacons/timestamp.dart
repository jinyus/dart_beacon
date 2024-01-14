part of '../base_beacon.dart';

typedef TimestampValue<T> = ({T value, DateTime timestamp});

class TimestampBeacon<T> extends ReadableBeacon<TimestampValue<T>> {
  TimestampBeacon({T? initialValue, super.debugLabel})
      : super(
            initialValue: initialValue != null || null is T
                ? (value: initialValue as T, timestamp: DateTime.now())
                : null);

  void set(T newValue) {
    _setValue((value: newValue, timestamp: DateTime.now()));
  }
}
