// ignore_for_file: use_setters_to_change_properties

part of '../producer.dart';

// ignore: public_member_api_docs
typedef BeaconFilter<T> = bool Function(T?, T);

/// A beacon that filters updates to its value based on a function.
class FilteredBeacon<T> extends WritableBeacon<T> {
  /// @macro [FilteredBeacon]
  FilteredBeacon({
    super.initialValue,
    BeaconFilter<T>? filter,
    super.name,
    this.lazyBypass = true,
  }) : _filter = filter;

  BeaconFilter<T>? _filter;

  /// Whether or not this beacon has a filter.
  bool get hasFilter => _filter != null;

  /// Whether values should be filtered out if the beacon is empty.
  ///
  final bool lazyBypass;

  /// Set the function that will be used to filter subsequent values.
  void setFilter(BeaconFilter<T> newFilter) {
    _filter = newFilter;
  }

  @override
  void _internalSet(T newValue, {bool force = false, bool delegated = false}) {
    if (delegated && _delegate != null) {
      _delegate!.set(newValue, force: true);
      return;
    }

    final shouldBypass = isEmpty && lazyBypass;

    if (shouldBypass ||
        (_filter?.call(isEmpty ? null : peek(), newValue) ?? true)) {
      _setValue(newValue, force: force);
    }
  }
}
