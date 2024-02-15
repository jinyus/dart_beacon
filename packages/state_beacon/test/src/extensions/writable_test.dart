import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/extensions/extensions.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should convert to a value notifier', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toValueNotifier();

    expect(valueNotifier, isA<ValueNotifier<int>>());

    var called = 0;

    valueNotifier.addListener(() => called++);

    beacon.value = 1;

    BeaconScheduler.flush();

    expect(called, 1);

    beacon.value = 2;

    BeaconScheduler.flush();

    expect(called, 2);

    valueNotifier.dispose();

    beacon.value = 3;

    BeaconScheduler.flush();

    expect(called, 2);
  });

  test('should not notify after source beacon is disposed', () {
    BeaconScheduler.use60fpsScheduler(); // just to test it out for coverage

    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toValueNotifier();

    expect(valueNotifier, isA<ValueNotifier<int>>());

    var called = 0;

    valueNotifier.addListener(() => called++);

    beacon.value = 1;

    BeaconScheduler.flush();

    expect(called, 1);

    beacon.value = 2;

    BeaconScheduler.flush();

    expect(called, 2);

    beacon
      ..dispose()
      ..value = 3;

    BeaconScheduler.flush();

    expect(called, 2);
  });

  test('should return the same notifier instance', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toValueNotifier();
    final valueNotifier2 = beacon.toValueNotifier();
    final valueNotifier3 = beacon.toValueNotifier();

    expect(valueNotifier, valueNotifier2);
    expect(valueNotifier2, valueNotifier3);

    expect(hasNotifier(beacon), isTrue);

    beacon.dispose();

    expect(hasNotifier(beacon), isFalse);
  });

  test('should remove notifier from cache when notifier is disposed.', () {
    final age = Beacon.writable(50);
    final name = Beacon.writable('bob');

    final aNotifier = age.toValueNotifier();
    final nNotifier = name.toValueNotifier();

    expect(hasNotifier(age), isTrue);
    expect(hasNotifier(name), isTrue);
    expect(age.listenersCount, 1);
    expect(name.listenersCount, 1);

    aNotifier.dispose();

    expect(hasNotifier(age), isFalse);
    expect(hasNotifier(name), isTrue);
    expect(age.listenersCount, 0);

    nNotifier.dispose();

    expect(hasNotifier(age), isFalse);
    expect(hasNotifier(name), isFalse);
    expect(name.listenersCount, 0);
  });
}
