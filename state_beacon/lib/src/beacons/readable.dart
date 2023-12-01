part of '../base_beacon.dart';

class ReadableBeacon<T> extends BaseBeacon<T> {
  ReadableBeacon([T? initialValue]) {
    if (initialValue != null) {
      _initialValue = initialValue;
      _value = initialValue;
    }
  }
}
