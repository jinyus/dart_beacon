part of '../base_beacon.dart';

/// A beacon that holds a set of values.
class SetBeacon<E> extends WritableBeacon<Set<E>> {
  /// @macro [SetBeacon]
  SetBeacon(
    Set<E> initialValue, {
    super.name,
  }) : super(initialValue: initialValue);

  /// Adds [value] to the set.
  ///
  /// Returns `true` if [value] (or an equal value) was not yet in the set.
  /// Otherwise returns `false` and the set is not changed.
  ///
  /// Example:
  /// ```dart
  /// final dateTimes = <DateTime>{};
  /// final time1 = DateTime.fromMillisecondsSinceEpoch(0);
  /// final time2 = DateTime.fromMillisecondsSinceEpoch(0);
  /// // time1 and time2 are equal, but not identical.
  /// assert(time1 == time2);
  /// assert(!identical(time1, time2));
  /// final time1Added = dateTimes.add(time1);
  /// print(time1Added); // true
  /// // A value equal to time2 exists already in the set, and the call to
  /// // add doesn't change the set.
  /// final time2Added = dateTimes.add(time2);
  /// print(time2Added); // false
  ///
  /// print(dateTimes); // {1970-01-01 02:00:00.000}
  /// assert(dateTimes.length == 1);
  /// assert(identical(time1, dateTimes.first));
  /// print(dateTimes.length);
  /// ```
  void add(E value) {
    _value.add(value);
    _setValue(_value, force: true);
  }

  /// Adds all elements in [iterable] to this set.
  ///
  /// Equivalent to adding each element in [iterable] using [add],
  /// but some collections may be able to optimize it.
  /// ```dart
  /// final characters = <String>{'A', 'B'};
  /// characters.addAll({'A', 'B', 'C'});
  /// print(characters); // {A, B, C}
  /// ```
  void addAll(Iterable<E> iterable) {
    _value.addAll(iterable);
    _setValue(_value, force: true);
  }

  /// Removes all elements from the set.
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// characters.clear(); // {}
  /// ```
  void clear() {
    _value.clear();
    _setValue(_value, force: true);
  }

  /// Removes [value] from the set.
  ///
  /// Returns `true` if [value] was in the set, and `false` if not.
  /// The method has no effect if [value] was not in the set.
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// final didRemoveB = characters.remove('B'); // true
  /// final didRemoveD = characters.remove('D'); // false
  /// print(characters); // {A, C}
  /// ```
  bool remove(Object? value) {
    final result = _value.remove(value);
    _setValue(_value, force: true);
    return result;
  }

  /// Removes all elements of this set that satisfy [test].
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// characters.removeWhere((element) => element.startsWith('B'));
  /// print(characters); // {A, C}
  /// ```
  void removeWhere(bool Function(E element) test) {
    _value.removeWhere(test);
    _setValue(_value, force: true);
  }

  /// Removes all elements of this set that fail to satisfy [test].
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// characters.retainWhere(
  ///     (element) => element.startsWith('B') || element.startsWith('C'));
  /// print(characters); // {B, C}
  /// ```
  void retainWhere(bool Function(E element) test) {
    _value.retainWhere(test);
    _setValue(_value, force: true);
  }

  /// Removes each element of [iterable] from this set.
  /// ```dart
  /// final characters = <String>{'A', 'B', 'C'};
  /// characters.removeAll({'A', 'B', 'X'});
  /// print(characters); // {C}
  /// ```
  void removeAll(Iterable<E> iterable) {
    _value.removeAll(iterable);
    _setValue(_value, force: true);
  }

  /// Clears the set
  @override
  void reset({bool force = false}) {
    clear();
  }
}
