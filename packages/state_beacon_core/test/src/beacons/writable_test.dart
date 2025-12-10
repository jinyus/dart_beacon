// ignore_for_file: cascade_invocations

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

// rm: scoped writable

void main() {
  test('should notify listeners when value changes', () async {
    final beacon = Beacon.writable(10);
    var ran = 0;
    beacon.subscribe((_) => ran++);

    BeaconScheduler.flush();
    expect(ran, 1);

    beacon.value = 20;

    BeaconScheduler.flush();
    expect(ran, 2);
  });

  test('should not notify listeners when the value remains unchanged',
      () async {
    final beacon = Beacon.writable<int>(10);
    var ran = 0;
    beacon.subscribe((_) => ran++);

    BeaconScheduler.flush();
    expect(ran, 1);

    beacon.value = 10;
    BeaconScheduler.flush();
    expect(ran, 1);
  });

  test('should reset the value to initial state', () {
    final beacon = Beacon.writable<int>(10);

    beacon
      ..set(20)
      ..reset();

    expect(beacon.value, 10);
  });

  test('should subscribe and unsubscribe correctly', () async {
    final beacon = Beacon.writable<int>(10);
    var ran = 0;

    final unsubscribe = beacon.subscribe((_) => ran++);
    BeaconScheduler.flush();
    expect(ran, 1);

    beacon.value = 20;
    BeaconScheduler.flush();
    expect(ran, 2);

    unsubscribe();
    BeaconScheduler.flush();
    expect(ran, 2);
  });

  test('should notify multiple listeners', () async {
    final beacon = Beacon.writable<int>(10);
    var ran1 = 0;
    var ran2 = 0;

    beacon.subscribe((_) => ran1++);
    beacon.subscribe((_) => ran2++);

    BeaconScheduler.flush();
    expect(ran1, 1);
    expect(ran2, 1);

    beacon.value = 20;
    beacon.value = 21;

    BeaconScheduler.flush();
    expect(ran1, 2);
    expect(ran2, 2);
  });

  test('should lazily initialize its value', () async {
    final wBeacon = Beacon.lazyWritable<int>();
    expect(
      () => wBeacon.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );
    wBeacon.set(10);
    expect(wBeacon.value, equals(10));

    final fBeacon = Beacon.lazyFiltered<int>(filter: (prev, next) => next > 5);
    expect(
      () => fBeacon.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );
    fBeacon.set(10);
    expect(fBeacon.value, equals(10));

    const k10ms = Duration(milliseconds: 10);
    final dBeacon = Beacon.lazyDebounced<int>(duration: k10ms);
    expect(
      () => dBeacon.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );
    dBeacon.set(10);
    await delay(k10ms * 2);
    expect(dBeacon.value, equals(10));

    final tBeacon = Beacon.lazyThrottled<int>(duration: k10ms);
    expect(
      () => tBeacon.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );
    tBeacon.set(10);
    expect(tBeacon.value, equals(10));

    final tsBeacon = Beacon.lazyTimestamped<int>();
    expect(
      () => tsBeacon.value,
      throwsA(isA<UninitializeLazyReadException>()),
    );

    tsBeacon.set(10);
    expect(tsBeacon.value.value, equals(10));

    final uBeacon = Beacon.lazyUndoRedo<int>();

    try {
      uBeacon.value;
    } catch (e) {
      expect(e, isA<UninitializeLazyReadException>());
      expect(e.toString(), contains(uBeacon.name));
    }

    try {
      uBeacon.peek();
    } catch (e) {
      expect(e, isA<Error>());
    }

    uBeacon.set(10);
    expect(uBeacon.value, 10);
  });

  test('should have previousValue null on first initialization', () {
    final beacon = Beacon.lazyWritable<int>();
    expect(beacon.previousValue, isNull);

    beacon.value = 20;
    expect(beacon.previousValue, isNull);

    beacon.value = 30;
    expect(beacon.previousValue, 20);
  });

  test('should notify when same value is set with force option', () async {
    final beacon = Beacon.writable(10);
    const time = Duration(milliseconds: 5);
    final throttleBeacon = Beacon.throttled(10, duration: time);
    final debounceBeacon = Beacon.debounced(10, duration: time);
    final filterBeacon = Beacon.filtered(10, filter: (prev, next) => next > 5);
    final undoRedoBeacon = Beacon.undoRedo(10);

    var called = 0;
    var tCalled = 0;
    var dCalled = 0;
    var fCalled = 0;
    var uCalled = 0;

    beacon.subscribe((_) => called++);
    throttleBeacon.subscribe((_) => tCalled++);
    debounceBeacon.subscribe((_) => dCalled++);
    filterBeacon.subscribe((_) => fCalled++);
    undoRedoBeacon.subscribe((_) => uCalled++);

    BeaconScheduler.flush();

    expect(called, 1);
    expect(tCalled, 1);
    expect(dCalled, 1);
    expect(fCalled, 1);
    expect(uCalled, 1);

    beacon.value = 20;
    BeaconScheduler.flush();
    beacon.set(20, force: true);
    BeaconScheduler.flush();
    beacon.set(20, force: true);
    BeaconScheduler.flush();
    expect(called, 4);

    throttleBeacon.set(10, force: true);
    BeaconScheduler.flush();
    expect(tCalled, 2);

    debounceBeacon.set(10, force: true);
    await delay();
    expect(dCalled, 2);

    filterBeacon.set(10, force: true);
    BeaconScheduler.flush();
    filterBeacon.set(10, force: true);
    BeaconScheduler.flush();
    expect(fCalled, 3);

    undoRedoBeacon.set(10, force: true);
    BeaconScheduler.flush();
    undoRedoBeacon.set(10, force: true);
    BeaconScheduler.flush();
    expect(uCalled, 3);

    await delay();

    throttleBeacon.set(10, force: true);
    BeaconScheduler.flush();
    expect(tCalled, 3);
  });
}
