import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should set previous and initial values', () {
    var beacon = Beacon.list([]);
    beacon.value = [1, 2, 3];
    expect(beacon.previousValue, equals([]));
    beacon.value = [4, 5, 6];
    expect(beacon.previousValue, equals([1, 2, 3]));
    expect(beacon.initialValue, []);
  });

  test('should notify listeners when list is modified', () {
    var nums = Beacon.list<int>([1, 2, 3]);

    var called = 0;

    nums.subscribe((_) => called++);

    nums.add(4);

    expect(called, 1);

    expect(nums.value, equals([1, 2, 3, 4]));

    nums.remove(2);

    expect(nums.value, equals([1, 3, 4]));

    expect(called, 2);

    nums[0] = 10;

    expect(nums.value, equals([10, 3, 4]));

    expect(called, 3);

    nums.addAll([5, 6, 7]);

    expect(nums.value, equals([10, 3, 4, 5, 6, 7]));

    expect(called, 4);

    nums.length = 2;

    expect(nums.value, equals([10, 3]));

    expect(called, 5);

    nums.clear();

    expect(nums.value, equals([]));

    expect(called, 6);

    nums.insert(0, 1);

    expect(nums.value, equals([1]));

    expect(called, 7);

    nums.fillRange(0, 1, 1);

    expect(nums.value, equals([1]));

    expect(called, 8);

    nums.insertAll(1, [2, 3]);

    expect(nums.value, equals([1, 2, 3]));

    expect(called, 9);

    nums.mapInPlace((e) => e * 2);

    expect(called, 10);

    expect(nums.value, equals([2, 4, 6]));

    nums.remove(6);

    expect(nums.value, equals([2, 4]));

    nums.removeAt(1);

    expect(nums.value, equals([2]));

    nums.removeLast();

    expect(nums.value, equals([]));

    nums.addAll([1, 2, 3, 4, 5]);

    expect(nums.value, equals([1, 2, 3, 4, 5]));

    nums.removeRange(1, 3);

    expect(nums.value, equals([1, 4, 5]));

    nums.removeWhere((e) => e % 2 == 0);

    expect(nums.value, equals([1, 5]));

    nums.replaceRange(1, 2, [2, 3]);

    expect(nums.value, equals([1, 2, 3]));

    nums.retainWhere((e) => e > 2);

    expect(nums.value, equals([3]));

    nums.setAll(0, [1]);

    expect(nums.value, equals([1]));

    nums.value = [1, 2, 3, 4];

    nums.setRange(0, 2, [3, 4]);

    expect(nums.value, equals([3, 4, 3, 4]));

    nums.shuffle();

    expect(nums.value.length, equals(4));

    nums.sort();

    expect(nums.value, equals([3, 3, 4, 4]));

    nums.value = [1, 2, 3, 4];

    expect(nums.value, equals([1, 2, 3, 4]));

    nums.first = 10;

    expect(nums.value, equals([10, 2, 3, 4]));

    nums.last = 20;

    expect(nums.value, equals([10, 2, 3, 20]));

    expect(called, 26);
  });
}
