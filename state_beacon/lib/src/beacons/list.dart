part of '../base_beacon.dart';

class ListBeacon<E> extends WritableBeacon<List<E>> implements List<E> {
  ListBeacon(super.value);

  @override
  E get first => value.first;

  @override
  set first(E val) {
    value.first = val;
    _notifyListeners();
  }

  @override
  E get last => value.last;

  @override
  set last(E val) {
    value.last = val;
    _notifyListeners();
  }

  @override
  int get length => value.length;

  @override
  set length(int value) {
    this.value.length = value;
    _notifyListeners();
  }

  @override
  List<E> operator +(List<E> other) {
    return value + other;
  }

  @override
  E operator [](int index) {
    return value[index];
  }

  @override
  void operator []=(int index, E value) {
    this.value[index] = value;
    _notifyListeners();
  }

  @override
  void add(E value) {
    this.value.add(value);
    _notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    value.addAll(iterable);
    _notifyListeners();
  }

  @override
  bool any(bool Function(E element) test) {
    return value.any(test);
  }

  @override
  Map<int, E> asMap() {
    return value.asMap();
  }

  @override
  List<R> cast<R>() {
    return value.cast<R>();
  }

  @override
  void clear() {
    value.clear();
    _notifyListeners();
  }

  @override
  bool contains(Object? element) {
    return value.contains(element);
  }

  @override
  E elementAt(int index) {
    return value.elementAt(index);
  }

  @override
  bool every(bool Function(E element) test) {
    return value.every(test);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    return value.expand<T>(toElements);
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    value.fillRange(start, end, fillValue);
    _notifyListeners();
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.firstWhere(test, orElse: orElse);
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return value.fold<T>(initialValue, combine);
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) {
    return value.followedBy(other);
  }

  @override
  void forEach(void Function(E element) action) {
    value.forEach(action);
  }

  @override
  Iterable<E> getRange(int start, int end) {
    return value.getRange(start, end);
  }

  @override
  int indexOf(E element, [int start = 0]) {
    return value.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) {
    return value.indexWhere(test, start);
  }

  @override
  void insert(int index, E element) {
    value.insert(index, element);
    _notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    value.insertAll(index, iterable);
    _notifyListeners();
  }

  @override
  bool get isEmpty => value.isEmpty;

  @override
  bool get isNotEmpty => value.isNotEmpty;

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  String join([String separator = ""]) {
    return value.join(separator);
  }

  @override
  int lastIndexOf(E element, [int? start]) {
    return value.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    return value.lastIndexWhere(test, start);
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.lastWhere(test, orElse: orElse);
  }

  @override
  Iterable<T> map<T>(T Function(E e) toElement) {
    return value.map(toElement);
  }

  void mapInPlace(E Function(E) toElement) {
    for (var i = 0; i < value.length; i++) {
      this[i] = toElement(value[i]);
    }
    _notifyListeners();
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    return value.reduce(combine);
  }

  @override
  bool remove(Object? value) {
    final result = this.value.remove(value);
    _notifyListeners();
    return result;
  }

  @override
  E removeAt(int index) {
    final result = value.removeAt(index);
    _notifyListeners();
    return result;
  }

  @override
  E removeLast() {
    final result = value.removeLast();
    _notifyListeners();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    value.removeRange(start, end);
    _notifyListeners();
  }

  @override
  void removeWhere(bool Function(E element) test) {
    value.removeWhere(test);
    _notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    value.replaceRange(start, end, replacements);
    _notifyListeners();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    value.retainWhere(test);
    _notifyListeners();
  }

  @override
  Iterable<E> get reversed => value.reversed;

  @override
  void setAll(int index, Iterable<E> iterable) {
    value.setAll(index, iterable);
    _notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    value.setRange(start, end, iterable, skipCount);
    _notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    value.shuffle(random);
    _notifyListeners();
  }

  @override
  E get single => value.single;

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    return value.singleWhere(test, orElse: orElse);
  }

  @override
  Iterable<E> skip(int count) {
    return value.skip(count);
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return value.skipWhile(test);
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    value.sort(compare);
    _notifyListeners();
  }

  @override
  List<E> sublist(int start, [int? end]) {
    return value.sublist(start, end);
  }

  @override
  Iterable<E> take(int count) {
    return value.take(count);
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return value.takeWhile(test);
  }

  @override
  List<E> toList({bool growable = true}) {
    return value.toList(growable: growable);
  }

  @override
  Set<E> toSet() {
    return value.toSet();
  }

  @override
  Iterable<E> where(bool Function(E element) test) {
    return value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }

  @override
  bool operator ==(Object other) {
    return other is ListBeacon<E> && value == other.value;
  }

  @override
  int get hashCode {
    return this.hashCode ^ value.hashCode;
  }
}
