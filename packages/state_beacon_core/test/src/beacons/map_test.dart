// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should set previous and initial values', () {
    final beacon = Beacon.hashMap<String, int>({});
    beacon.value = {'a': 1, 'b': 2};
    expect(beacon.previousValue, equals(<String, int>{}));
    beacon.value = {'c': 3, 'd': 4};
    expect(beacon.previousValue, equals({'a': 1, 'b': 2}));
    expect(beacon.initialValue, <String, int>{});
  });

  test('should notify listeners when map is modified', () async {
    final data = Beacon.hashMap<String, int>({});

    var called = 0;

    data.subscribe((_) => called++);

    await BeaconScheduler.settle();

    expect(called, 1);

    data['a'] = 1;

    await BeaconScheduler.settle();

    expect(called, 2);
    expect(data.value, equals({'a': 1}));

    data.addAll({'b': 2, 'c': 3});

    await BeaconScheduler.settle();

    expect(called, 3);
    expect(data.value, equals({'a': 1, 'b': 2, 'c': 3}));

    data.remove('b');

    await BeaconScheduler.settle();

    expect(called, 4);
    expect(data.value, equals({'a': 1, 'c': 3}));

    data.update('a', (value) => value + 2);

    await BeaconScheduler.settle();

    expect(called, 5);
    expect(data.value, equals({'a': 3, 'c': 3}));

    data.clear();

    await BeaconScheduler.settle();

    expect(called, 6);
    expect(data.value, equals(<String, int>{}));

    data.addAll({'d': 4, 'e': 5});

    await BeaconScheduler.settle();

    expect(called, 7);
    expect(data.value, equals({'d': 4, 'e': 5}));

    data.removeWhere((key, value) => key.startsWith('d'));

    await BeaconScheduler.settle();

    expect(called, 8);
    expect(data.value, equals({'e': 5}));

    data.putIfAbsent('a', () => 1);

    await BeaconScheduler.settle();

    expect(called, 9);
    expect(data.value, equals({'e': 5, 'a': 1}));

    data.updateAll((key, value) => value + 1);

    expect(data.value, equals({'e': 6, 'a': 2}));

    data.reset();

    expect(data.value, equals(<String, int>{}));

    await BeaconScheduler.settle();

    expect(called, 10);
  });
}
