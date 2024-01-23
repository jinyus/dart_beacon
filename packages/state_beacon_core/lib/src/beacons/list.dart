part of '../base_beacon.dart';

class ListBeacon<E> extends WritableBeacon<List<E>> {
  ListBeacon(
    List<E> initialValue, {
    super.name,
  }) : super(initialValue: initialValue);

  set first(E val) {
    value.first = val;
    _setValue(_value, force: true);
  }

  set last(E val) {
    value.last = val;
    _setValue(_value, force: true);
  }

  set length(int value) {
    this.value.length = value;
    _setValue(_value, force: true);
  }

  void operator []=(int index, E value) {
    _value[index] = value;
    _setValue(_value, force: true);
  }

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

  void fillRange(int start, int end, [E? fillValue]) {
    _value.fillRange(start, end, fillValue);
    _setValue(_value, force: true);
  }

  void insert(int index, E element) {
    _value.insert(index, element);
    _setValue(_value, force: true);
  }

  void insertAll(int index, Iterable<E> iterable) {
    _value.insertAll(index, iterable);
    _setValue(_value, force: true);
  }

  void mapInPlace(E Function(E) toElement) {
    for (var i = 0; i < _value.length; i++) {
      // using this[i]=  would trigger a notification for each element
      _value[i] = toElement(_value[i]);
    }
    _setValue(_value, force: true);
  }

  bool remove(Object? value) {
    final result = _value.remove(value);
    _setValue(_value, force: true);
    return result;
  }

  E removeAt(int index) {
    final result = _value.removeAt(index);
    _setValue(_value, force: true);
    return result;
  }

  E removeLast() {
    final result = _value.removeLast();
    _setValue(_value, force: true);
    return result;
  }

  void removeRange(int start, int end) {
    _value.removeRange(start, end);
    _setValue(_value, force: true);
  }

  void removeWhere(bool Function(E element) test) {
    _value.removeWhere(test);
    _setValue(_value, force: true);
  }

  void replaceRange(int start, int end, Iterable<E> replacements) {
    _value.replaceRange(start, end, replacements);
    _setValue(_value, force: true);
  }

  void retainWhere(bool Function(E element) test) {
    _value.retainWhere(test);
    _setValue(_value, force: true);
  }

  void setAll(int index, Iterable<E> iterable) {
    _value.setAll(index, iterable);
    _setValue(_value, force: true);
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _value.setRange(start, end, iterable, skipCount);
    _setValue(_value, force: true);
  }

  void shuffle([Random? random]) {
    _value.shuffle(random);
    _setValue(_value, force: true);
  }

  void sort([int Function(E a, E b)? compare]) {
    _value.sort(compare);
    _setValue(_value, force: true);
  }

  /// Clears the list
  @override
  void reset() {
    clear();
  }
}
