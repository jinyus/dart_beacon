import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should notify listeners when value changes', () {
    var beacon = Beacon.writable(10);
    var called = false;
    beacon.subscribe((_) => called = true);
    beacon.value = 20;
    expect(called, isTrue);
  });

  test('should not notify listeners when the value remains unchanged', () {
    var beacon = Beacon.writable<int>(10);
    var callCount = 0;
    beacon.subscribe((_) => callCount++);
    beacon.value = 10;
    expect(callCount, equals(0));
  });

  test('should reset the value to initial state', () {
    var beacon = Beacon.writable<int>(10);
    beacon.value = 20;
    beacon.reset();
    expect(beacon.value, equals(10));
  });

  test('should subscribe and unsubscribe correctly', () {
    var beacon = Beacon.writable<int>(10);
    var callCount = 0;

    var unsubscribe = beacon.subscribe((_) => callCount++);
    beacon.value = 20;
    expect(callCount, equals(1));

    unsubscribe();
    beacon.value = 30;
    expect(callCount, equals(1)); // No additional call after unsubscribing
  });

  test('should notify multiple listeners', () {
    var beacon = Beacon.writable<int>(10);
    var callCount1 = 0;
    var callCount2 = 0;

    beacon.subscribe((_) => callCount1++);
    beacon.subscribe((_) => callCount2++);

    beacon.value = 20;
    beacon.value = 21;
    expect(callCount1, equals(2));
    expect(callCount2, equals(2));
  });

  test('should return a function that can write to the beacon', () {
    var (count, setCount) = Beacon.scopedWritable(0);
    var called = 0;
    count.subscribe((_) => called++);
    setCount(10);
    expect(count.value, equals(10));
    expect(called, equals(1));
    setCount(20);
    expect(count.value, equals(20));
    expect(called, equals(2));
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
    await Future.delayed(k10ms * 2);
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
      expect(e.toString(), contains(uBeacon.debugLabel));
    }

    uBeacon.set(10);
    expect(uBeacon.value, equals(10));
  });

  test('should notify when same value is set with force option', () async {
    var beacon = Beacon.writable(10);
    const time = Duration(milliseconds: 5);
    var throttleBeacon = Beacon.throttled(10, duration: time);
    var debounceBeacon = Beacon.debounced(10, duration: time);
    var filterBeacon = Beacon.filtered(10, filter: (prev, next) => next > 5);
    var undoRedoBeacon = UndoRedoBeacon(initialValue: 10);

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

    beacon.value = 20;
    beacon.set(20, force: true);
    beacon.set(20, force: true);
    throttleBeacon.set(10, force: true);
    debounceBeacon.set(10, force: true);
    filterBeacon.set(10, force: true);
    filterBeacon.set(10, force: true);
    undoRedoBeacon.set(10, force: true);
    undoRedoBeacon.set(10, force: true);

    await Future.delayed(Duration(milliseconds: 6));

    throttleBeacon.set(10, force: true);

    expect(called, equals(3));
    expect(tCalled, equals(2));
    expect(dCalled, equals(1));
    expect(fCalled, equals(2));
    expect(uCalled, equals(2));
  });
}
