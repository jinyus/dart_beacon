import 'package:test/test.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

void main() {
  test('should set previous and initial values', () {
    var beacon = Beacon.hashSet<int>({});
    beacon.value = {1, 2, 3};
    expect(beacon.previousValue, equals(<int>{}));
    beacon.value = {4, 5, 6};
    expect(beacon.previousValue, equals({1, 2, 3}));
    expect(beacon.initialValue, <int>{});
  });

  test('should notify listeners when set is modified', () {
    var nums = Beacon.hashSet<int>({1, 2, 3});

    var called = 0;

    nums.subscribe((_) => called++);

    nums.add(4);

    expect(called, 1);

    expect(nums.value, equals({1, 2, 3, 4}));

    nums.remove(2);

    expect(nums.value, equals({1, 3, 4}));

    expect(called, 2);

    nums.addAll({5, 6, 7});

    expect(nums.value, equals({1, 3, 4, 5, 6, 7}));

    expect(called, 3);

    nums.clear();

    expect(nums.value, equals(<int>{}));

    expect(called, 4);

    nums.addAll({1, 2, 3});

    expect(nums.value, equals({1, 2, 3}));

    expect(called, 5);

    nums.remove(2);

    expect(nums.value, equals({1, 3}));

    expect(called, 6);

    nums.addAll({4, 5, 6});

    expect(nums.value, equals({1, 3, 4, 5, 6}));

    expect(called, 7);

    nums.removeWhere((e) => e % 2 == 0);

    expect(nums.value, equals({1, 3, 5}));

    expect(called, 8);

    nums.retainWhere((e) => e > 2);

    expect(nums.value, equals({3, 5}));

    expect(called, 9);

    nums.removeAll({3});

    expect(nums.value, equals({5}));

    nums.reset();

    expect(nums.value, equals(<int>{}));

    expect(called, 11);
  });
}
