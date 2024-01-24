// ignore_for_file: public_member_api_docs

part of '../base_beacon.dart';

/// A beacon that holds a set of values.
class SetBeacon<E> extends WritableBeacon<Set<E>> {
  /// @macro [SetBeacon]
  SetBeacon(
    Set<E> initialValue, {
    super.name,
  }) : super(initialValue: initialValue);

  void add(E value) {
    _value.add(value);
    _setValue(_value, force: true);
  }

  void addAll(Iterable<E> iterable) {
    _value.addAll(iterable);
    _setValue(_value, force: true);
  }

  void clear() {
    _value.clear();
    _setValue(_value, force: true);
  }

  bool remove(Object? value) {
    final result = _value.remove(value);
    _setValue(_value, force: true);
    return result;
  }

  void removeWhere(bool Function(E element) test) {
    _value.removeWhere(test);
    _setValue(_value, force: true);
  }

  void retainWhere(bool Function(E element) test) {
    _value.retainWhere(test);
    _setValue(_value, force: true);
  }

  void removeAll(Iterable<E> iterable) {
    _value.removeAll(iterable);
    _setValue(_value, force: true);
  }

  /// Clears the set
  @override
  void reset() {
    clear();
  }
}
