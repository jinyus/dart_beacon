// ignore_for_file: use_setters_to_change_properties

part of '../base_beacon.dart';

// ignore: public_member_api_docs
typedef BeaconFilter<T> = bool Function(T?, T);

/// A beacon that filters updates to its value based on a function.
class FilteredBeacon<T> extends WritableBeacon<T> {
  /// @macro [FilteredBeacon]
  FilteredBeacon({
    super.initialValue,
    BeaconFilter<T>? filter,
    super.name,
  }) : _filter = filter;

  BeaconFilter<T>? _filter;

  /// Whether or not this beacon has a filter.
  bool get hasFilter => _filter != null;

  /// Set the function that will be used to filter subsequent values.
  void setFilter(BeaconFilter<T> newFilter) {
    _filter = newFilter;
  }

  @override
  set value(T newValue) => set(newValue);

  @override
  void set(T newValue, {bool force = false}) {
    if (_isEmpty || (_filter?.call(peek(), newValue) ?? true)) {
      super.set(newValue, force: force);
    }
  }
}
