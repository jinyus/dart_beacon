part of '../producer.dart';

// ignore_for_file: avoid_setters_without_getters

/// A beacon that holds a list of values.
class ListBeacon<E> extends WritableBeacon<List<E>> {
  /// @macro [ListBeacon]
  ListBeacon(
    List<E> initialValue, {
    super.name,
  }) : super(initialValue: initialValue);

  /// Set the first element of the list.
  ///
  /// The list must be non-empty when accessing its first element.
  ///
  /// The first element of a list can be modified, unlike an [Iterable].
  /// A `list.first` is equivalent to `list[0]`,
  /// both for getting and setting the value.
  /// ```
  set first(E val) {
    value.first = val;
    _setValue(_value, force: true);
  }

  /// Set the last element of the list.
  ///
  /// The list must be non-empty when accessing its last element.
  ///
  /// The last element of a list can be modified, unlike an [Iterable].
  /// A `list.last` is equivalent to `theList[theList.length - 1]`,
  /// both for getting and setting the value.
  set last(E val) {
    value.last = val;
    _setValue(_value, force: true);
  }

  /// Setting the `length` changes the number of elements in the list.
  ///
  /// The list must be growable.
  /// If `newLength` is greater than current length,
  /// new entries are initialized to `null`,
  /// so `newLength` must not be greater than the current length
  /// if the element type [E] is non-nullable.
  ///
  /// ```dart
  /// final maybeNumbers = <int?>[1, null, 3];
  /// maybeNumbers.length = 5;
  /// print(maybeNumbers); // [1, null, 3, null, null]
  /// maybeNumbers.length = 2;
  /// print(maybeNumbers); // [1, null]
  ///
  /// final numbers = <int>[1, 2, 3];
  /// numbers.length = 1;
  /// print(numbers); // [1]
  /// numbers.length = 5; // Throws, cannot add `null`s.
  /// ```
  set length(int value) {
    this.value.length = value;
    _setValue(_value, force: true);
  }

  /// Sets the value at the given [index] in the list to [value].
  ///
  /// The [index] must be a valid index of this list,
  /// which means that `index` must be non-negative and
  /// less than [length].
  void operator []=(int index, E value) {
    _value[index] = value;
    _setValue(_value, force: true);
  }

  /// Adds [value] to the end of this list,
  /// extending the length by one.
  ///
  /// The list must be growable.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// numbers.add(4);
  /// print(numbers); // [1, 2, 3, 4]
  /// ```
  void add(E value) {
    _value.add(value);
    _setValue(_value, force: true);
  }

  /// Appends all objects of [iterable] to the end of this list.
  ///
  /// Extends the length of the list by the number of objects in [iterable].
  /// The list must be growable.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// numbers.addAll([4, 5, 6]);
  /// print(numbers); // [1, 2, 3, 4, 5, 6]
  /// ```
  void addAll(Iterable<E> iterable) {
    _value.addAll(iterable);
    _setValue(_value, force: true);
  }

  /// Removes all objects from this list; the length of the list becomes zero.
  ///
  /// The list must be growable.
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3];
  /// numbers.clear();
  /// print(numbers.length); // 0
  /// print(numbers); // []
  /// ```
  void clear() {
    _value.clear();
    _setValue(_value, force: true);
  }

  /// Overwrites a range of elements with [fillValue].
  ///
  /// Sets the positions greater than or equal to [start] and less than [end],
  /// to [fillValue].
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// If the element type is not nullable, the [fillValue] must be provided and
  /// must be non-`null`.
  ///
  /// Example:
  /// ```dart
  /// final words = List.filled(5, 'old');
  /// print(words); // [old, old, old, old, old]
  /// words.fillRange(1, 3, 'new');
  /// print(words); // [old, new, new, old, old]
  /// ```
  void fillRange(int start, int end, [E? fillValue]) {
    _value.fillRange(start, end, fillValue);
    _setValue(_value, force: true);
  }

  /// Inserts [element] at position [index] in this list.
  ///
  /// This increases the length of the list by one and shifts all objects
  /// at or after the index towards the end of the list.
  ///
  /// The list must be growable.
  /// The [index] value must be non-negative and no greater than [length].
  ///
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4];
  /// const index = 2;
  /// numbers.insert(index, 10);
  /// print(numbers); // [1, 2, 10, 3, 4]
  /// ```
  void insert(int index, E element) {
    _value.insert(index, element);
    _setValue(_value, force: true);
  }

  /// Inserts all objects of [iterable] at position [index] in this list.
  ///
  /// This increases the length of the list by the length of [iterable] and
  /// shifts all later objects towards the end of the list.
  ///
  /// The list must be growable.
  /// The [index] value must be non-negative and no greater than [length].
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4];
  /// final insertItems = [10, 11];
  /// numbers.insertAll(2, insertItems);
  /// print(numbers); // [1, 2, 10, 11, 3, 4]
  /// ```
  void insertAll(int index, Iterable<E> iterable) {
    _value.insertAll(index, iterable);
    _setValue(_value, force: true);
  }

  /// Like List.map, but updates the list in place.
  void mapInPlace(E Function(E) toElement) {
    for (var i = 0; i < _value.length; i++) {
      // using this[i]=  would trigger a notification for each element
      _value[i] = toElement(_value[i]);
    }
    _setValue(_value, force: true);
  }

  /// Removes the first occurrence of [value] from this list.
  ///
  /// Returns true if [value] was in the list, false otherwise.
  /// The list must be growable.
  ///
  /// ```dart
  /// final parts = <String>['head', 'shoulders', 'knees', 'toes'];
  /// final retVal = parts.remove('head'); // true
  /// print(parts); // [shoulders, knees, toes]
  /// ```
  /// The method has no effect if [value] was not in the list.
  /// ```dart
  /// final parts = <String>['shoulders', 'knees', 'toes'];
  /// // Note: 'head' has already been removed.
  /// final retVal = parts.remove('head'); // false
  /// print(parts); // [shoulders, knees, toes]
  /// ```
  bool remove(Object? value) {
    final result = _value.remove(value);
    if (result) {
      _setValue(_value, force: true);
    }
    return result;
  }

  /// Removes the object at position [index] from this list.
  ///
  /// This method reduces the length of `this` by one and moves
  /// all later objects down by one position.
  ///
  /// Returns the removed value.
  ///
  /// The [index] must be in the range `0 ≤ index < length`.
  /// The list must be growable.
  /// ```dart
  /// final parts = <String>['head', 'shoulder', 'knees', 'toes'];
  /// final retVal = parts.removeAt(2); // knees
  /// print(parts); // [head, shoulder, toes]
  /// ```
  E removeAt(int index) {
    final result = _value.removeAt(index);
    _setValue(_value, force: true);
    return result;
  }

  /// Removes and returns the last object in this list.
  ///
  /// The list must be growable and non-empty.
  /// ```dart
  /// final parts = <String>['head', 'shoulder', 'knees', 'toes'];
  /// final retVal = parts.removeLast(); // toes
  /// print(parts); // [head, shoulder, knees]
  /// ```
  E removeLast() {
    final result = _value.removeLast();
    _setValue(_value, force: true);
    return result;
  }

  /// Removes a range of elements from the list.
  ///
  /// Removes the elements with positions greater than or equal to [start]
  /// and less than [end], from the list.
  /// This reduces the list's length by `end - start`.
  ///
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The list must be growable.
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// numbers.removeRange(1, 4);
  /// print(numbers); // [1, 5]
  /// ```
  void removeRange(int start, int end) {
    _value.removeRange(start, end);
    _setValue(_value, force: true);
  }

  /// Removes all objects from this list that satisfy [test].
  ///
  /// An object `o` satisfies [test] if `test(o)` is true.
  /// ```dart
  /// final numbers = <String>['one', 'two', 'three', 'four'];
  /// numbers.removeWhere((item) => item.length == 3);
  /// print(numbers); // [three, four]
  /// ```
  /// The list must be growable.
  void removeWhere(bool Function(E element) test) {
    _value.removeWhere(test);
    _setValue(_value, force: true);
  }

  /// Replaces a range of elements with the elements of [replacements].
  ///
  /// Removes the objects in the range from [start] to [end],
  /// then inserts the elements of [replacements] at [start].
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// final replacements = [6, 7];
  /// numbers.replaceRange(1, 4, replacements);
  /// print(numbers); // [1, 6, 7, 5]
  /// ```
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The operation `list.replaceRange(start, end, replacements)`
  /// is roughly equivalent to:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// numbers.removeRange(1, 4);
  /// final replacements = [6, 7];
  /// numbers.insertAll(1, replacements);
  /// print(numbers); // [1, 6, 7, 5]
  /// ```
  /// but may be more efficient.
  ///
  /// The list must be growable.
  /// This method does not work on fixed-length lists, even when [replacements]
  /// has the same number of elements as the replaced range. In that case use
  /// [setRange] instead.
  void replaceRange(int start, int end, Iterable<E> replacements) {
    _value.replaceRange(start, end, replacements);
    _setValue(_value, force: true);
  }

  /// Removes all objects from this list that fail to satisfy [test].
  ///
  /// An object `o` satisfies [test] if `test(o)` is true.
  /// ```dart
  /// final numbers = <String>['one', 'two', 'three', 'four'];
  /// numbers.retainWhere((item) => item.length == 3);
  /// print(numbers); // [one, two]
  /// ```
  /// The list must be growable.
  void retainWhere(bool Function(E element) test) {
    _value.retainWhere(test);
    _setValue(_value, force: true);
  }

  /// Overwrites elements with the objects of [iterable].
  ///
  /// The elements of [iterable] are written into this list,
  /// starting at position [index].
  /// This operation does not increase the length of the list.
  ///
  /// The [index] must be non-negative and no greater than [length].
  ///
  /// The [iterable] must not have more elements than what can fit from [index]
  /// to [length].
  ///
  /// If `iterable` is based on this list, its values may change _during_ the
  /// `setAll` operation.
  /// ```dart
  /// final list = <String>['a', 'b', 'c', 'd'];
  /// list.setAll(1, ['bee', 'sea']);
  /// print(list); // [a, bee, sea, d]
  /// ```
  void setAll(int index, Iterable<E> iterable) {
    _value.setAll(index, iterable);
    _setValue(_value, force: true);
  }

  /// Writes some elements of [iterable] into a range of this list.
  ///
  /// Copies the objects of [iterable], skipping [skipCount] objects first,
  /// into the range from [start], inclusive, to [end], exclusive, of this list.
  /// ```dart
  /// final list1 = <int>[1, 2, 3, 4];
  /// final list2 = <int>[5, 6, 7, 8, 9];
  /// // Copies the 4th and 5th items in list2 as the 2nd and 3rd items
  /// // of list1.
  /// const skipCount = 3;
  /// list1.setRange(1, 3, list2, skipCount);
  /// print(list1); // [1, 8, 9, 4]
  /// ```
  /// The provided range, given by [start] and [end], must be valid.
  /// A range from [start] to [end] is valid if 0 ≤ `start` ≤ `end` ≤ [length].
  /// An empty range (with `end == start`) is valid.
  ///
  /// The [iterable] must have enough objects to fill the range from `start`
  /// to `end` after skipping [skipCount] objects.
  ///
  /// If `iterable` is this list, the operation correctly copies the elements
  /// originally in the range from `skipCount` to `skipCount + (end - start)` to
  /// the range `start` to `end`, even if the two ranges overlap.
  ///
  /// If `iterable` depends on this list in some other way, no guarantees are
  /// made.
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _value.setRange(start, end, iterable, skipCount);
    _setValue(_value, force: true);
  }

  /// Shuffles the elements of this list randomly.
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 4, 5];
  /// numbers.shuffle();
  /// print(numbers); // [1, 3, 4, 5, 2] OR some other random result.
  /// ```
  void shuffle([Random? random]) {
    _value.shuffle(random);
    _setValue(_value, force: true);
  }

  /// Sorts this list according to the order
  /// specified by the [compare] function.
  ///
  /// The [compare] function must act as a [Comparator].
  /// ```dart
  /// final numbers = <String>['two', 'three', 'four'];
  /// // Sort from shortest to longest.
  /// numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers); // [two, four, three]
  /// ```
  /// The default [List] implementations use [Comparable.compare] if
  /// [compare] is omitted.
  /// ```dart
  /// final numbers = <int>[13, 2, -11, 0];
  /// numbers.sort();
  /// print(numbers); // [-11, 0, 2, 13]
  /// ```
  /// In that case, the elements of the list must be [Comparable] to
  /// each other.
  ///
  /// A [Comparator] may compare objects as equal (return zero), even if they
  /// are distinct objects.
  /// The sort function is not guaranteed to be stable, so distinct objects
  /// that compare as equal may occur in any order in the result:
  /// ```dart
  /// final numbers = <String>['one', 'two', 'three', 'four'];
  /// numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(numbers); // [one, two, four, three] OR [two, one, four, three]
  /// ```
  void sort([int Function(E a, E b)? compare]) {
    _value.sort(compare);
    _setValue(_value, force: true);
  }

  /// Clears the list
  @override
  void reset({bool force = false}) {
    clear();
  }
}
