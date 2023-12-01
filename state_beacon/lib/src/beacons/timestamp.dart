part of '../base_beacon.dart';

typedef TimestampValue<T> = ({T value, DateTime timestamp});

class TimestampBeacon<T> extends BaseBeacon<TimestampValue<T>> {
  TimestampBeacon(T initialValue)
      : super((value: initialValue, timestamp: DateTime.now()));

  void set(T newValue) {
    _setValue((value: newValue, timestamp: DateTime.now()));
  }
}
