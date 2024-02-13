// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should set previous and initial values', () {
    final beacon = Beacon.hashSet<int>({});
    beacon.value = {1, 2, 3};
    expect(beacon.previousValue, equals(<int>{}));
    beacon.value = {4, 5, 6};
    expect(beacon.previousValue, equals({1, 2, 3}));
    expect(beacon.initialValue, <int>{});
  });

  test('should notify listeners when set is modified', () async {
    final nums = Beacon.hashSet<int>({1, 2, 3});

    var called = 0;

    nums.subscribe((_) => called++);

    nums.add(4);

    await BeaconScheduler.settle();

    expect(called, 1);

    expect(nums.value, equals({1, 2, 3, 4}));

    nums.remove(2);

    expect(nums.value, equals({1, 3, 4}));

    await BeaconScheduler.settle();

    expect(called, 2);

    nums.addAll({5, 6, 7});

    expect(nums.value, equals({1, 3, 4, 5, 6, 7}));

    await BeaconScheduler.settle();

    expect(called, 3);

    nums.clear();

    expect(nums.value, equals(<int>{}));

    await BeaconScheduler.settle();

    expect(called, 4);

    nums.addAll({1, 2, 3});

    expect(nums.value, equals({1, 2, 3}));

    await BeaconScheduler.settle();

    expect(called, 5);

    nums.remove(2);

    expect(nums.value, equals({1, 3}));

    await BeaconScheduler.settle();

    expect(called, 6);

    nums.addAll({4, 5, 6});

    expect(nums.value, equals({1, 3, 4, 5, 6}));

    await BeaconScheduler.settle();

    expect(called, 7);

    nums.removeWhere((e) => e.isEven);

    expect(nums.value, equals({1, 3, 5}));

    await BeaconScheduler.settle();

    expect(called, 8);

    nums.retainWhere((e) => e > 2);

    expect(nums.value, equals({3, 5}));

    await BeaconScheduler.settle();

    expect(called, 9);

    nums.removeAll({3});

    expect(nums.value, equals({5}));

    nums.reset();

    expect(nums.value, equals(<int>{}));

    await BeaconScheduler.settle();

    expect(called, 10);
  });
}
