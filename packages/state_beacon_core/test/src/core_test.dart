// ignore_for_file:  prefer_final_locals, cascade_invocations

import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../common.dart';

Future<void> _delay([int milliseconds = 0]) {
  return Future.delayed(Duration(milliseconds: milliseconds));
}

void main() {
  /* 
          a  b
          | /
          c
  */
  test('2 Beacon.writables', () {
    var a = Beacon.writable(7);
    var b = Beacon.writable(1);

    var called = 0;

    var c = Beacon.derived(() {
      called++;
      return a.value * b.value;
    });

    a.value = 2;

    expect(c.value, 2);

    b.value = 3;

    expect(c.value, 6);

    expect(called, 2);

    c.value;

    expect(called, 2);
  });

  /* 
        a  b
        | /
        c
        |
        d
  */
  test('dependent Derived', () {
    var a = Beacon.writable(7);
    var b = Beacon.writable(1);

    var called = 0;

    var c = Beacon.derived(() {
      called++;
      return a.value * b.value;
    });

    var called2 = 0;

    var d = Beacon.derived(() {
      called2++;
      return c.value + 1;
    });

    expect(d.value, 8);
    expect(called, 1);
    expect(called2, 1);
    a.value = 3;
    expect(d.value, 4);
    expect(called, 2);
    expect(called2, 2);
  });

  /*
          a
          |
          c
  */
  test('equality check', () {
    var called = 0;
    var a = Beacon.writable(7);
    var c = Beacon.derived(() {
      called++;
      return a.value + 10;
    });

    c.value;
    c.value;

    expect(called, 1);
    a.value = 7;
    expect(called, 1);
  });

  /*
        a     b
        |     |
        cA   cB
        |   / (dynamically depends on cB)
        cAB
  */
  test('dynamic Derived', () {
    var a = Beacon.writable(1);
    var b = Beacon.writable(2);

    var calledA = 0;
    var calledB = 0;
    var calledAB = 0;

    var cA = Beacon.derived(() {
      calledA++;
      return a.value;
    });

    var cB = Beacon.derived(() {
      calledB++;
      return b.value;
    });

    var cAB = Beacon.derived(() {
      calledAB++;
      return cA.value > 0 ? cA.value : cB.value;
    });

    expect(cAB.value, 1);

    a.value = 2;
    b.value = 3;

    expect(cAB.value, 2);

    expect(calledA, 2);
    expect(calledAB, 2);
    expect(calledB, 0);

    a.value = 0;

    expect(cAB.value, 3);

    expect(calledA, 3);
    expect(calledAB, 3);
    expect(calledB, 1);

    b.value = 4;

    expect(cAB.value, 4);

    expect(calledA, 3);
    expect(calledAB, 4);
    expect(calledB, 2);
  });

  /* 
          a  
          | 
          b (=)
          |
          c
  */
  test('boolean equality check', () {
    var a = Beacon.writable(0, name: 'a');
    var b = Beacon.derived(() => a.value > 0, name: 'b');
    var called = 0;
    var c = Beacon.derived(
      () {
        called++;
        var i = b.value ? 1 : 0;
        return i > 0 ? 1 : 0;
      },
      name: 'c',
    );

    expect(c.value, 0);
    expect(c.value, 0);
    expect(called, 1);

// print('\nset 1\n');
    a.value = 1;
    expect(c.value, 1);
    expect(called, 2);

// print('\nset 2\n');
    a.value = 2;
    expect(c.value, 1);
    expect(called, 2); // shouldn't run because bool didn't change
  });

  /*
        s
        |
        a
        | \ 
        b  c
         \ |
           d
  */
  test('diamond Derived', () {
    var s = Beacon.writable(1);
    var a = Beacon.derived(() => s.value);
    var b = Beacon.derived(() => a.value * 2);
    var c = Beacon.derived(() => a.value * 3);
    var called = 0;

    var d = Beacon.derived(() {
      called++;
      return b.value + c.value;
    });

    expect(d.value, 5);
    expect(called, 1);

    s.value = 2;
    expect(d.value, 10);
    expect(called, 2);

    s.value = 3;
    expect(d.value, 15);
    expect(called, 3);
  });

  test('set inside Derived', () {
    var s = Beacon.writable(1);
    var a = Beacon.derived(() {
      s.value = 2;
      return 0;
    });
    var l = Beacon.derived(() => s.value + 100);

    a.value;
    expect(l.value, 102);
  });

  test('effect runs on flushEffects', () {
    var src = Beacon.writable(7);
    var effectCalled = 0;

    Beacon.effect(() {
      effectCalled++;
      src.value;
    });

    expect(effectCalled, 0);

    BeaconScheduler.flush();

    expect(effectCalled, 1);

    src.value = 8;

    expect(effectCalled, 1);

    BeaconScheduler.flush();

    expect(effectCalled, 2);
  });

  test('async modify in reaction before await', () {
    var s = Beacon.writable(1);
    var a = Beacon.derived(() async {
      s.value = 2;
      await _delay(1);
      return 0;
    });
    var l = Beacon.derived(() => s.value + 100);

    a.value;

    expect(l.value, 102);
  });

  test('async modify in reaction after await', () {
    var s = Beacon.writable(1);
    var a = Beacon.derived(() async {
      await _delay(1);
      s.value = 2;
      return 0;
    });
    var l = Beacon.derived(() => s.value + 100);

    a.value;

    expect(l.value, 101);
  });

  test('should dispose effects', () {
    var s = Beacon.writable(1);
    var effectCalled = 0;

    var dispose = Beacon.effect(() {
      effectCalled++;
      s.value;
    });

    expect(effectCalled, 0);

    BeaconScheduler.flush();

    expect(effectCalled, 1);

    s.value = 2;

    BeaconScheduler.flush();

    expect(effectCalled, 2);

    dispose();

    s.value = 3;

    BeaconScheduler.flush();

    expect(effectCalled, 2);
  });

  test('should batch updates', () async {
    final age = Beacon.writable<int>(10);
    var callCount = 0;
    age.subscribe((_) => callCount++);

    age
      ..value = 5
      ..value = 16
      ..value = 20
      ..value = 23;

    BeaconScheduler.flush();

    // There were 4 updates, but only 1 notification
    // In synchronous mode, there are 4 notifications
    expect(callCount, 1);
  });

  test('toString should work correctly', () {
    final beacon = Beacon.writable(10);
    expect(beacon.toString(), 'Writable<int>(10)');

    final fbeacon = Beacon.lazyFiltered<int>();
    expect(fbeacon.toString(), 'LazyFilteredBeacon<int>(uninitialized)');

    final nbeacon = Beacon.writable(10, name: 'num');
    expect(nbeacon.toString(), 'num(10)');

    final lnbeacon = Beacon.lazyWritable<int>(name: 'num');
    expect(lnbeacon.toString(), 'num(uninitialized)');
  });

  group('Previous value Tests', () {
    test('should set previous and initial values - writable', () {
      final beacon = Beacon.writable(10);
      beacon.value = 20;
      expect(beacon.previousValue, equals(10));
      beacon.value = 30;
      expect(beacon.previousValue, equals(20));

      beacon.reset();
      expect(beacon.previousValue, equals(30));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - readable', () {
      final beacon = Beacon.readable(10);
      expect(beacon.previousValue, equals(null));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - undoredo', () {
      final beacon = Beacon.undoRedo(10);
      beacon.value = 20;
      expect(beacon.previousValue, equals(10));
      beacon.value = 30;
      expect(beacon.previousValue, equals(20));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - timestamp', () {
      final beacon = Beacon.timestamped(10);
      beacon.set(20);
      expect(beacon.previousValue?.value, equals(10));
      beacon.set(30);
      expect(beacon.previousValue?.value, equals(20));
      expect(beacon.initialValue.value, 10);
    });

    test('should set previous and initial values - throttled', () async {
      final beacon = Beacon.throttled(10, duration: k10ms);
      beacon.set(20);
      expect(beacon.previousValue, equals(10));
      await delay(k10ms * 1.1);
      beacon.set(30);
      expect(beacon.previousValue, equals(20));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - filtered', () {
      final beacon = Beacon.lazyFiltered<int>(filter: (p, x) => x > 5);
      beacon.set(10);
      expect(beacon.previousValue, equals(10));
      beacon.set(15);
      expect(beacon.previousValue, equals(10));
      beacon.set(5);
      expect(beacon.previousValue, equals(10));
      beacon.set(25);
      expect(beacon.previousValue, equals(15));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - derived', () async {
      final count = Beacon.writable(0);
      final beacon = Beacon.derived(() => count.value * 2);
      beacon.subscribe((p0) {});
      BeaconScheduler.flush();
      count.set(1);
      BeaconScheduler.flush();
      expect(beacon.previousValue, equals(0));
      count.set(5);
      BeaconScheduler.flush();
      expect(beacon.previousValue, equals(2));
      expect(beacon.initialValue, 0);
    });

    test('should set lastdata', () async {
      // BeaconObserver.instance = LoggingObserver();
      final count = Beacon.writable(0);
      final beacon = Beacon.future(() async => count.value * 2);

      expect(beacon.value, isA<AsyncLoading<int>>());
      await delay(k1ms);
      expect(beacon.value.unwrap(), equals(0));

      final buff = beacon.bufferTime(duration: k10ms);

      count.set(1);

      await delay(k1ms);

      count.set(5);

      await delay(k10ms);

      expect(buff.value, [
        AsyncData(0),
        AsyncLoading<int>(),
        AsyncData(2),
        AsyncLoading<int>(),
        AsyncData(10),
      ]);

      expect(buff.value[1].lastData, 0);
      expect(buff.value[3].lastData, 2);
    });

    test('should set previous and initial values - debounced', () async {
      final beacon = Beacon.debounced<int>(5, duration: k10ms);

      beacon.set(10);
      await delay(k10ms * 1.1);
      expect(beacon.previousValue, equals(5));

      beacon.set(15);
      await delay(k10ms * 1.1);
      expect(beacon.previousValue, equals(10));

      expect(beacon.initialValue, equals(5));
    });

    test('should set previous and initial values - buffered', () async {
      final beacon = Beacon.bufferedCount<int>(2);

      beacon.add(5);
      beacon.add(5);
      expect(beacon.previousValue, equals([]));

      beacon.add(15);
      beacon.add(15);
      expect(beacon.previousValue, equals([5, 5]));

      beacon.add(25);
      beacon.add(25);
      expect(beacon.previousValue, equals([15, 15]));

      expect(beacon.initialValue, equals([]));
    });
  });
}
