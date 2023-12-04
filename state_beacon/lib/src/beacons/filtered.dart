part of '../base_beacon.dart';

typedef BeaconFilter<T> = bool Function(T?, T);

class FilteredBeacon<T> extends WritableBeacon<T> {
  final BeaconFilter<T> filter;

  FilteredBeacon({T? initialValue, required this.filter}) : super(initialValue);

  @override
  set value(T newValue) => set(newValue);

  @override
  void set(T newValue, {bool force = false}) {
    if (_isEmpty || filter(_previousValue, newValue)) {
      super.set(newValue, force: force);
    }
  }
}
