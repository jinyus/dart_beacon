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

  test('should notify listeners when map is modified', () {
    final data = Beacon.hashMap<String, int>({});

    var called = 0;

    data.subscribe((_) => called++);

    data['a'] = 1;

    expect(called, 1);
    expect(data.value, equals({'a': 1}));

    data.addAll({'b': 2, 'c': 3});

    expect(called, 2);
    expect(data.value, equals({'a': 1, 'b': 2, 'c': 3}));

    data.remove('b');

    expect(called, 3);
    expect(data.value, equals({'a': 1, 'c': 3}));

    data.update('a', (value) => value + 2);

    expect(called, 4);
    expect(data.value, equals({'a': 3, 'c': 3}));

    data.clear();

    expect(called, 5);
    expect(data.value, equals(<String, int>{}));

    data.addAll({'d': 4, 'e': 5});

    expect(called, 6);
    expect(data.value, equals({'d': 4, 'e': 5}));

    data.removeWhere((key, value) => key.startsWith('d'));

    expect(called, 7);
    expect(data.value, equals({'e': 5}));

    data.putIfAbsent('a', () => 1);

    expect(called, 8);
    expect(data.value, equals({'e': 5, 'a': 1}));

    data.updateAll((key, value) => value + 1);

    expect(data.value, equals({'e': 6, 'a': 2}));

    data.reset();

    expect(data.value, equals(<String, int>{}));

    expect(called, 10);
  });
}
