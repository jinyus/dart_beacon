part of '../base_beacon.dart';

typedef BeaconFilter<T> = bool Function(T?, T);

class FilteredBeacon<T> extends WritableBeacon<T> {
  BeaconFilter<T>? _filter;

  FilteredBeacon({T? initialValue, BeaconFilter<T>? filter})
      : _filter = filter,
        super(initialValue);

  bool get hasFilter => _filter != null;

  @override
  set value(T newValue) => set(newValue);

  // Set the function that will be used to filter subsequent values.
  void setFilter(BeaconFilter<T> newFilter) {
    _filter = newFilter;
  }

  @override
  void set(T newValue, {bool force = false}) {
    if (_isEmpty || (_filter?.call(_previousValue, newValue) ?? true)) {
      super.set(newValue, force: force);
    }
  }
}
