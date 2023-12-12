part of '../base_beacon.dart';

class ListBeacon<E> extends WritableBeacon<List<E>> implements List<E> {
  ListBeacon(super.initialValue);

  @override
  E get first => _value.first;

  @override
  set first(E val) {
    _value.first = val;
    _notifyListeners();
  }

  @override
  E get last => _value.last;

  @override
  set last(E val) {
    _value.last = val;
    _notifyListeners();
  }

  @override
  int get length => _value.length;

  @override
  set length(int value) {
    _value.length = value;
    _notifyListeners();
  }

  @override
  List<E> operator +(List<E> other) {
    return _value + other;
  }

  @override
  E operator [](int index) {
    return _value[index];
  }

  @override
  void operator []=(int index, E value) {
    _value[index] = value;
    _notifyListeners();
  }

  @override
  void add(E value) {
    _value.add(value);
    _notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    _value.addAll(iterable);
    _notifyListeners();
  }

  @override
  bool any(bool Function(E element) test) {
    return _value.any(test);
  }

  @override
  Map<int, E> asMap() {
    return _value.asMap();
  }

  @override
  List<R> cast<R>() {
    return _value.cast<R>();
  }

  @override
  void clear() {
    _value.clear();
    _notifyListeners();
  }

  @override
  bool contains(Object? element) {
    return _value.contains(element);
  }

  @override
  E elementAt(int index) {
    return _value.elementAt(index);
  }

  @override
  bool every(bool Function(E element) test) {
    return _value.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    return _value.expand<T>(toElements);
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    _value.fillRange(start, end, fillValue);
    _notifyListeners();
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _value.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return _value.fold<T>(initialValue, combine);
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return _value.followedBy(other);
  }

  @override
  void forEach(void Function(E element) action) {
    _value.forEach(action);
  }

  @override
  Iterable<E> getRange(int start, int end) {
    return _value.getRange(start, end);
  }

  @override
  int indexOf(E element, [int start = 0]) {
    return _value.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) {
    return _value.indexWhere(test, start);
  }

  @override
  void insert(int index, E element) {
    _value.insert(index, element);
    _notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _value.insertAll(index, iterable);
    _notifyListeners();
  }

  @override
  bool get isEmpty => _value.isEmpty;

  @override
  bool get isNotEmpty => _value.isNotEmpty;

  @override
  Iterator<E> get iterator => _value.iterator;

  @override
  String join([String separator = ""]) {
    return _value.join(separator);
  }

  @override
  int lastIndexOf(E element, [int? start]) {
    return _value.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    return _value.lastIndexWhere(test, start);
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _value.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    return _value.map(toElement);
  }

  void mapInPlace(E Function(E) toElement) {
    for (var i = 0; i < _value.length; i++) {
      this[i] = toElement(_value[i]);
    }
    _notifyListeners();
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    return _value.reduce(combine);
  }

  @override
  bool remove(Object? value) {
    final result = _value.remove(value);
    _notifyListeners();
    return result;
  }

  @override
  E removeAt(int index) {
    final result = _value.removeAt(index);
    _notifyListeners();
    return result;
  }

  @override
  E removeLast() {
    final result = _value.removeLast();
    _notifyListeners();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    _value.removeRange(start, end);
    _notifyListeners();
  }

  @override
  void removeWhere(bool Function(E element) test) {
    _value.removeWhere(test);
    _notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    _value.replaceRange(start, end, replacements);
    _notifyListeners();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    _value.retainWhere(test);
    _notifyListeners();
  }

  @override
  Iterable<E> get reversed => _value.reversed;

  @override
  void setAll(int index, Iterable<E> iterable) {
    _value.setAll(index, iterable);
    _notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _value.setRange(start, end, iterable, skipCount);
    _notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    _value.shuffle(random);
    _notifyListeners();
  }

  @override
  E get single => _value.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    return _value.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<E> skip(int count) {
    return _value.skip(count);
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return _value.skipWhile(test);
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    _value.sort(compare);
    _notifyListeners();
  }

  @override
  List<E> sublist(int start, [int? end]) {
    return _value.sublist(start, end);
  }

  @override
  Iterable<E> take(int count) {
    return _value.take(count);
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return _value.takeWhile(test);
  }

  @override
  List<E> toList({bool growable = true}) {
    return _value.toList(growable: growable);
  }

  @override
  Set<E> toSet() {
    return _value.toSet();
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    return _value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _value.whereType<T>();
  }
}
