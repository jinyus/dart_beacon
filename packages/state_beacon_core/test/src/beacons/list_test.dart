import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should set previous and initial values', () {
    final beacon = Beacon.list<int>([]);

    // ignore: cascade_invocations
    beacon.value = [1, 2, 3];
    expect(beacon.previousValue, equals([]));
    beacon.value = [4, 5, 6];
    expect(beacon.previousValue, equals([1, 2, 3]));
    expect(beacon.initialValue, <int>[]);
  });

  test('should notify listeners when list is modified', () async {
    final nums = Beacon.list<int>([1, 2, 3]);

    var called = 0;

    nums.subscribe((_) => called++);

    BeaconScheduler.flush();

    expect(called, 1);

    nums.add(4);

    expect(nums.value, equals([1, 2, 3, 4]));

    nums.remove(2);

    expect(nums.value, equals([1, 3, 4]));

    BeaconScheduler.flush();

    expect(called, 2);

    nums[0] = 10;

    expect(nums.value, equals([10, 3, 4]));

    BeaconScheduler.flush();

    expect(called, 3);

    nums.addAll([5, 6, 7]);

    expect(nums.value, equals([10, 3, 4, 5, 6, 7]));

    BeaconScheduler.flush();

    expect(called, 4);

    nums.length = 2;

    expect(nums.value, equals([10, 3]));

    BeaconScheduler.flush();

    expect(called, 5);

    nums.clear();

    expect(nums.value, equals([]));

    BeaconScheduler.flush();

    expect(called, 6);

    nums.insert(0, 1);

    expect(nums.value, equals([1]));

    BeaconScheduler.flush();

    expect(called, 7);

    nums.fillRange(0, 1, 1);

    expect(nums.value, equals([1]));

    BeaconScheduler.flush();

    expect(called, 8);

    nums.insertAll(1, [2, 3]);

    expect(nums.value, equals([1, 2, 3]));

    BeaconScheduler.flush();

    expect(called, 9);

    nums.mapInPlace((e) => e * 2);

    BeaconScheduler.flush();

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

    nums.removeWhere((e) => e.isEven);

    expect(nums.value, equals([1, 5]));

    nums.replaceRange(1, 2, [2, 3]);

    expect(nums.value, equals([1, 2, 3]));

    nums.retainWhere((e) => e > 2);

    expect(nums.value, equals([3]));

    nums.setAll(0, [1]);

    expect(nums.value, equals([1]));

    nums
      ..value = [1, 2, 3, 4]
      ..setRange(0, 2, [3, 4]);

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

    BeaconScheduler.flush();

    expect(called, 11); // all should be batched
  });

  test('should not notify when remove() fails to find element', () {
    final nums = Beacon.list<int>([1, 2, 3]);

    var called = 0;

    nums.subscribe((_) => called++);

    BeaconScheduler.flush();

    expect(called, 1);

    final result = nums.remove(99);

    expect(result, false);
    expect(nums.value, equals([1, 2, 3]));

    BeaconScheduler.flush();

    expect(called, 1);
  });
}
