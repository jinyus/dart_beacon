part of '../base_beacon.dart';

class MapBeacon<K, V> extends WritableBeacon<Map<K, V>> {
  MapBeacon(
    Map<K, V> initialValue, {
    super.debugLabel,
  }) : super(initialValue: initialValue);

  void operator []=(K key, V value) {
    _value[key] = value;
    _setValue(_value, force: true);
  }

  void addAll(Map<K, V> other) {
    _value.addAll(other);
    _setValue(_value, force: true);
  }

  void clear() {
    _value.clear();
    _setValue(_value, force: true);
  }

  V? remove(Object? key) {
    final result = _value.remove(key);
    _setValue(_value, force: true);
    return result;
  }

  void update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    _value.update(key, update, ifAbsent: ifAbsent);
    _setValue(_value, force: true);
  }

  void updateAll(V Function(K key, V value) update) {
    _value.updateAll(update);
    _setValue(_value, force: true);
  }

  void removeWhere(bool Function(K key, V value) predicate) {
    _value.removeWhere(predicate);
    _setValue(_value, force: true);
  }

  V? putIfAbsent(K key, V Function() ifAbsent) {
    final result = _value.putIfAbsent(key, ifAbsent);
    _setValue(_value, force: true);
    return result;
  }

  /// Clears the map
  @override
  void reset() {
    clear();
  }
}
