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
  void _onNewValueFromWrapped(I value) {
    _setValue(mapFN(value), force: true);
  }
}
