// ignore_for_file: use_setters_to_change_properties

part of '../producer.dart';

// ignore: public_member_api_docs
typedef MapFilter<I, O> = O Function(I);

/// A beacon that transforms all values before setting them.
class _MappedBeacon<I, O> extends ReadableBeacon<O> with BeaconWrapper<I, O> {
  _MappedBeacon(
    this.mapFN, {
    super.initialValue,
    super.name,
  });

  final MapFilter<I, O> mapFN;

  @override
  void set(I newValue, {bool force = false}) {
    _internalSet(newValue, force: force, delegated: true);
  }

  void _internalSet(I newValue, {bool force = false, bool delegated = false}) {
    // map can never be set publicly because it is a readable beacon.
    // if (delegated && _delegate != null) {
    //   _delegate!.set(newValue, force: true);
    //   return;
    // }

    _setValue(mapFN(newValue), force: force);
  }

  @override
  void _onNewValueFromWrapped(I value) {
    _internalSet(value);
  }

  @override
  void reset({bool force = false}) {
    if (_isEmpty) return;

    // map can never be reset publicly because it is a readable beacon.
    // if (_delegate != null) {
    //   _delegate!.reset(force: force);
    //   // return;
    // }

    _setValue(_initialValue, force: force);
  }
}
