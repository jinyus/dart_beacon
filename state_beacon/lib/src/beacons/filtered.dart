part of '../base_beacon.dart';

typedef BeaconFilter<T> = bool Function(T?, T);

class FilteredBeacon<T> extends WritableBeacon<T> {
  final BeaconFilter<T> filter;

  FilteredBeacon(super.initialValue, {required this.filter});

  @override
  set value(T newValue) {
    if (filter(_previousValue, newValue)) {
      super.value = newValue;
    }
  }
}
