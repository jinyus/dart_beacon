import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  const k10ms = Duration(milliseconds: 10);
  group('Beacon Tests', () {
    test('should set initial value', () {
      var beacon = Beacon.writable(10);
      expect(beacon.peek(), equals(10));
    });
    test('should notify listeners when value changes', () {
      var beacon = Beacon.writable(10);
      var called = false;
      beacon.subscribe((_) => called = true);
      beacon.value = 20;
      expect(called, isTrue);
    });

    test('should decrease listenersCount when unsubscribed', () {
      var beacon = Beacon.writable(10);

      final unsub1 = beacon.subscribe((_) {});

      expect(beacon.listenersCount, 1);

      final unsub2 = Beacon.createEffect(() {
        beacon.value;
      });

      expect(beacon.listenersCount, 2);

      unsub1();

      expect(beacon.listenersCount, 1);

      unsub2();

      expect(beacon.listenersCount, 0);
    });

    test('should notify when same value is set with force option', () async {
      var beacon = Beacon.writable(10);
      const time = Duration(milliseconds: 5);
      var throttleBeacon = Beacon.throttled(10, duration: time);
      var debounceBeacon = Beacon.debounced(10, duration: time);
      var filterBeacon = Beacon.filtered(10, (prev, next) => next > 5);
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

    test('should conditionally stop listening to beacons', () {
      final name = Beacon.writable("Bob");
      final age = Beacon.writable(20);
      final college = Beacon.writable("MIT");

      var called = 0;
      Beacon.createEffect(() {
        called++;
        // ignore: unused_local_variable
        var msg = '${name.value} is ${age.value} years old';

        if (age.value > 21) {
          msg += ' and can go to ${college.value}';
        }

        // print(msg);
      });

      name.value = "Alice";
      age.value = 21;
      college.value = "Stanford";
      age.value = 22;
      college.value = "Harvard";
      age.value = 18;

      // Should stop listening to college beacon because age is less than 21
      college.value = "Yale";

      expect(called, equals(6));
    });

    test('should fire subscription immediately', () async {
      final a = Beacon.writable(1);
      final completer = Completer<int>();

      a.subscribe(completer.complete, startNow: true);

      final result = await completer.future;

      expect(result, 1);
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

    test('should update value only after specified duration', () async {
      final beacon =
          Beacon.debounced('', duration: Duration(milliseconds: 100));
      var called = 0;

      beacon.subscribe((_) => called++);

      // simulate typing
      beacon.value = 'a';
      beacon.value = 'ap';
      beacon.value = 'app';
      beacon.value = 'appl';
      beacon.value = 'apple';

      // Value should still be 0 immediately after setting it
      expect(beacon.value, equals(''));

      await Future.delayed(Duration(milliseconds: 150));

      expect(beacon.value, equals('apple')); // Value should be updated now

      expect(called, equals(1)); // Only one notification should be sent
    });

    test('should set throttle value updates', () async {
      var beacon = Beacon.throttled(10, duration: k10ms);

      beacon.set(20);
      expect(beacon.value, equals(20)); // first update allowed

      beacon.set(30);
      expect(beacon.value, equals(20)); // too fast, update ignored
      expect(beacon.isBlocked, true);

      await Future.delayed(k10ms * 1.1);

      beacon.set(30);
      expect(beacon.value, equals(30)); // throttle time passed, update allowed
    });

    test('should respect newly set throttle duration', () async {
      var beacon = Beacon.throttled(10, duration: k10ms);

      beacon.set(20);
      expect(beacon.value, equals(20)); // first update allowed

      beacon.set(30);
      expect(beacon.value, equals(20)); // too fast, update ignored

      beacon.setDuration(Duration.zero);

      beacon.set(30);
      expect(beacon.value, equals(30));
    });

    test('should not be blocked on reset and dispose', () async {
      var beacon = Beacon.throttled(10, duration: k10ms);

      beacon.set(20);
      expect(beacon.value, equals(20)); // first update allowed

      beacon.set(30);
      expect(beacon.value, equals(20)); // too fast, update ignored

      beacon.reset();

      beacon.set(30);
      expect(beacon.value, equals(30));

      beacon.set(40);
      expect(beacon.value, equals(30)); // too fast, update ignored

      beacon.dispose();

      beacon.set(40);
      expect(beacon.value, equals(40));
    });

    test('should update value at most once in specified duration', () async {
      final beacon = Beacon.throttled(0, duration: Duration(milliseconds: 100));
      var called = 0;

      beacon.subscribe((_) => called++);

      beacon.value = 10;
      expect(beacon.value, equals(10));

      beacon.value = 20;
      beacon.value = 30;
      beacon.value = 40;

      await Future.delayed(Duration(milliseconds: 50));

      expect(beacon.value, equals(10));

      await Future.delayed(Duration(milliseconds: 60));

      beacon.value = 30;

      expect(beacon.value, equals(30));

      // only ran twice even though value was updated 5 times
      expect(called, equals(2));
    });

    test('should buffer blocked updates', () async {
      final beacon = Beacon.lazyThrottled(
        duration: k10ms * 5,
        dropBlocked: false,
      );

      final values = <int>[];
      beacon.subscribe((value) {
        values.add(value);
      });

      beacon.set(1);
      expect(values, equals([1])); // first update is allowed

      beacon.set(2);
      await Future.delayed(Duration(milliseconds: 10));
      expect(values, equals([1])); // update blocked

      await Future.delayed(Duration(milliseconds: 55));

      expect(values, equals([1, 2])); // buffered update sent

      beacon.set(3);
      beacon.set(4);
      beacon.set(5);

      await Future.delayed(Duration(milliseconds: 10));

      expect(values, equals([1, 2])); // all blocked and buffered

      await Future.delayed(Duration(milliseconds: 100));

      expect(values, equals([1, 2, 3, 4]));

      await Future.delayed(Duration(milliseconds: 40));

      expect(values, equals([1, 2, 3, 4, 5]));
    });

    test('should update value only if it satisfies the filter criteria', () {
      var beacon = Beacon.filtered(0, (prev, next) => next > 5);
      beacon.value = 4;
      expect(beacon.value, equals(0)); // Value should not update

      beacon.value = 6;
      expect(beacon.value, equals(6)); // Value should update
    });

    test('should update value if filter function is null', () {
      var beacon = Beacon.filtered(0);
      beacon.value = 4;
      expect(beacon.value, equals(4)); // Value should update

      beacon.setFilter((p0, p1) => p1 > 10);

      beacon.value = 6;
      expect(beacon.value, equals(4)); // Value should not update

      beacon.value = 11;
      expect(beacon.value, equals(11)); // Value should update
    });

    test('should bypass filter function for first value', () {
      var beacon = Beacon.lazyFiltered<int>(filter: (prev, next) => next > 5);
      beacon.value = 4;
      expect(beacon.value, equals(4)); // Value should update

      beacon.value = 4;
      expect(beacon.value, equals(4)); // Value should not update

      beacon.value = 6;
      expect(beacon.value, equals(6)); // Value should update
    });

    test('should set hasFilter to false if not is provided', () {
      var beacon = Beacon.filtered(0);
      beacon.value = 4;
      expect(beacon.value, equals(4)); // Value should update

      expect(beacon.hasFilter, false);

      beacon.value = 5;
      expect(beacon.value, equals(5));

      beacon.setFilter((p0, p1) => p1 > 10);

      expect(beacon.hasFilter, true);

      beacon.value = 6;
      expect(beacon.value, equals(5)); // Value should not update

      beacon.value = 11;
      expect(beacon.value, equals(11)); // Value should update
    });

    test('should lazily initialize its value', () async {
      final wBeacon = Beacon.lazyWritable<int>();
      expect(
        () => wBeacon.value,
        throwsA(isA<UninitializeLazyReadException>()),
      );
      wBeacon.set(10);
      expect(wBeacon.value, equals(10));

      final fBeacon =
          Beacon.lazyFiltered<int>(filter: (prev, next) => next > 5);
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
      expect(
        () => uBeacon.value,
        throwsA(isA<UninitializeLazyReadException>()),
      );
      uBeacon.set(10);
      expect(uBeacon.value, equals(10));
    });

    test('should attach a timestamp to each value', () {
      var beacon = Beacon.timestamped(0);
      var timestampBefore = DateTime.now();
      beacon.set(10);
      var timestampAfter = DateTime.now();

      expect(beacon.value.value, equals(10)); // Check value
      expect(
        beacon.value.timestamp.isAfter(timestampBefore) &&
            beacon.value.timestamp.isBefore(timestampAfter),
        isTrue,
      );
    });
  });

  group('createEffect Tests', () {
    test('should run when a dependency changes', () {
      var beacon = Beacon.writable<int>(10);
      var effectCalled = false;

      Beacon.createEffect(() {
        effectCalled = true;
        beacon.value; // Dependency
      });

      // Should be true immediately after createEffect
      expect(effectCalled, isTrue);

      effectCalled = false; // Resetting for the next check
      beacon.value = 20;
      expect(effectCalled, isTrue);
    });

    test('should not run when dependencies are unchanged', () {
      var beacon = Beacon.writable<int>(10);
      var effectCalled = false;

      Beacon.createEffect(() {
        effectCalled = true;
        beacon.value; // Dependency
      });

      effectCalled = false; // Resetting for the next check
      beacon.value = 10;

      // Not changing the beacon value
      expect(effectCalled, isFalse);
    });

    test('should run when any of its multiple dependencies change', () {
      var beacon1 = Beacon.writable<int>(10);
      var beacon2 = Beacon.writable<int>(20);
      var effectCalled = false;

      Beacon.createEffect(() {
        effectCalled = true;
        beacon1.value;
        beacon2.value; // Multiple dependencies
      });

      beacon1.value = 15; // Changing one of the dependencies
      expect(effectCalled, isTrue);

      effectCalled = false; // Resetting for the next check
      beacon2.value = 25; // Changing the other dependency
      expect(effectCalled, isTrue);
    });

    test('should run immediately upon creation', () {
      var beacon = Beacon.writable<int>(10);
      var effectCalled = false;

      Beacon.createEffect(() {
        effectCalled = true;
        beacon.value;
      });

      // Should be true immediately after createEffect
      expect(effectCalled, isTrue);
    });

    test('should cancel the effect', () {
      var beacon = Beacon.writable(10);
      var effectCalled = false;

      var cancel = Beacon.createEffect(() {
        effectCalled = true;
        var _ = beacon.value;
      });

      cancel();
      effectCalled = false;

      beacon.value = 20;
      expect(effectCalled, isFalse);
    });

    test('should throw when effect mutates its dependency', () {
      var beacon1 = Beacon.writable<int>(10);

      try {
        Beacon.createEffect(() {
          Beacon.doBatchUpdate(() {
            beacon1.value++;
          });
        });
      } catch (e) {
        expect(e, isA<CircularDependencyException>());
      }
    });
  });

  group('Derived Tests', () {
    test('should only run immediately', () {
      final beacon = Beacon.writable(1);
      var effectCount = 0;

      final _ = Beacon.derived(() {
        effectCount++;
        return beacon.peek();
      });

      expect(effectCount, 1);
    });

    test('should not run immediately', () {
      final beacon = Beacon.writable(1);
      var effectCount = 0;

      final derived = Beacon.derived(() {
        effectCount++;
        return beacon.peek();
      }, manualStart: true);

      expect(effectCount, 0);

      derived.start();

      expect(effectCount, 1);
    });

    test('should update derived value when dependency changes', () {
      var beacon = Beacon.writable<int>(10);
      var derivedBeacon = Beacon.derived(() => beacon.value * 2);

      beacon.value = 20;
      expect(derivedBeacon.value, equals(40));
    });

    test('should be correct derived value upon initialization', () {
      var beacon = Beacon.writable<int>(10);
      var derivedBeacon = Beacon.derived(() => beacon.value * 2);

      expect(derivedBeacon.value, equals(20));
    });

    test('should run once per update', () {
      var beacon = Beacon.writable<int>(10);
      var called = 0;
      var derivedBeacon = Beacon.derived(() {
        called++;
        return beacon.value * 2;
      });

      beacon.value = 30;
      expect(derivedBeacon.value, equals(60));

      expect(called, equals(2));
    });

    test('should recompute when watching multiple dependencies', () {
      var beacon1 = Beacon.writable<int>(10);
      var beacon2 = Beacon.writable<int>(20);
      var derivedBeacon = Beacon.derived(() => beacon1.value + beacon2.value);

      beacon1.value = 15;
      expect(derivedBeacon.value, equals(35));

      beacon2.value = 25;
      expect(derivedBeacon.value, equals(40));
    });

    test('should throw when derived computation mutates', () {
      var beacon1 = Beacon.writable<int>(10);

      try {
        Beacon.derived(() => beacon1.value++);
      } catch (e) {
        expect(e, isA<CircularDependencyException>());
      }
    });

    test('should trigger rerun when accessed before async gap', () async {
      var count = Beacon.writable<int>(3);

      late var nums = Beacon.derived(() {
        return List.generate(count.value, (i) => i);
      });

      expect(nums.value, equals([0, 1, 2]));

      var numsDoubled = Beacon.derivedFuture(() async {
        // This will trigger a rerun because it is accessed before await
        var currentNums = nums.value;
        await Future.delayed(k10ms);
        return currentNums.map((e) => e * 2).toList();
      });

      await Future.delayed(k10ms * 2);

      expect(numsDoubled.value.unwrapValue(), equals([0, 2, 4]));

      count.value = 5;

      expect(nums.value, equals([0, 1, 2, 3, 4]));

      await Future.delayed(k10ms * 2);

      expect(numsDoubled.value.unwrapValue(), equals([0, 2, 4, 6, 8]));
    });
  });

  group('Beacon wrapping', () {
    test('should reflect original beacon value in wrapper beacon', () {
      var original = Beacon.readable<int>(10);
      var wrapper = Beacon.writable<int>(0);
      wrapper.wrap(original);

      expect(wrapper.value, equals(10));
    });

    test('should remove subscription for all wrapped beacons on dispose', () {
      var count = Beacon.readable<int>(10);
      var doubledCount = Beacon.derived<int>(() => count.value * 2);

      var wrapper = Beacon.writable<int>(0);

      wrapper.wrap(count);
      wrapper.wrap(doubledCount);

      expect(wrapper.value, equals(20));

      expect(doubledCount.listenersCount, 1);
      expect(count.listenersCount, 2);

      wrapper.clearWrapped();

      expect(doubledCount.listenersCount, 0);
      expect(count.listenersCount, 1);
    });

    test('should remove subscription for all wrapped beacons', () {
      var count = Beacon.readable<int>(10);
      var doubledCount = Beacon.derived<int>(() => count.value * 2);

      var wrapper = Beacon.bufferedCount<int>(5);

      wrapper.wrap(count, then: (b, c) => b.add(c));
      wrapper.wrap(doubledCount);

      expect(wrapper.value, equals([]));
      expect(wrapper.currentBuffer.value, [10, 20]);

      expect(doubledCount.listenersCount, 1);
      expect(count.listenersCount, 2);

      wrapper.clearWrapped();

      expect(doubledCount.listenersCount, 0);
      expect(count.listenersCount, 1);
    });

    test('should dispose internal currentBuffer on dispose', () {
      var beacon = Beacon.bufferedCount<int>(5);

      beacon.add(1);
      beacon.add(2);

      expect(beacon.currentBuffer.value, [1, 2]);

      beacon.dispose();

      expect(beacon.currentBuffer.value, []);
      expect(beacon.currentBuffer.isDisposed, true);
    });

    test('should apply transformation function', () {
      var original = Beacon.readable<int>(2);
      var wrapper = Beacon.writable<String>("");
      var bufWrapper = Beacon.bufferedCount<String>(10);

      wrapper.wrap(original, then: (w, val) => w.value = 'Number $val');
      bufWrapper.wrap(original, then: (w, val) => w.add('Number $val'));

      expect(wrapper.value, equals('Number 2'));
      expect(bufWrapper.currentBuffer.value, equals(['Number 2']));
    });

    test('should throw when no then function is supplied', () {
      var original = Beacon.readable<int>(2);
      var wrapper = Beacon.writable<String>("");
      var bufWrapper = Beacon.bufferedCount<String>(10);

      expect(() => wrapper.wrap(original),
          throwsA(isA<WrapTargetWrongTypeException>()));
      expect(
        () => bufWrapper.wrap(original),
        throwsA(isA<WrapTargetWrongTypeException>()),
      );
    });

    test('should throw when derived is started twice', () {
      var count = Beacon.readable<int>(2);
      var asText = Beacon.derived<String>(() => count.value.toString());

      expect(
        () => asText.start(),
        throwsA(isA<DerivedBeaconStartedTwiceException>()),
      );
    });

    test('should dispose internal status when disposed', () {
      var count = Beacon.readable<int>(2);
      var asText = Beacon.derived<String>(() => count.value.toString());

      expect(asText.value, count.value.toString());

      asText.dispose();

      expect(asText.isDisposed, true);
      expect(asText.status.isDisposed, true);
    });

    test('should throttle wrapped StreamBeacon', () async {
      final stream = Stream.periodic(Duration(milliseconds: 20), (i) => i);

      final numsFast = Beacon.stream(stream);
      final numsSlow = Beacon.throttled<AsyncValue<int>>(
        AsyncLoading(),
        duration: Duration(milliseconds: 200),
      );

      const maxCalls = 15;

      numsSlow.wrap(numsFast);
      var streamCalled = 0;
      var throttledCalled = 0;

      numsFast.subscribe((value) {
        if (streamCalled < maxCalls) {
          if (streamCalled == maxCalls - 1) {
            numsFast.unsubscribe();
          }

          streamCalled++;
        } else {
          throw Exception('Should not have been called');
        }
      });

      numsSlow.subscribe((value) {
        if (throttledCalled < maxCalls) {
          throttledCalled++;
        } else {
          throw Exception('Should not have been called');
        }
      });

      await Future.delayed(Duration(milliseconds: 400));

      expect(streamCalled, equals(15));
      expect(throttledCalled, equals(1));
    });
  });

  group('UndoRedoBeacon', () {
    test('should notify listeners when value changes', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0);
      var called = 0;

      beacon.subscribe((_) => called++);
      beacon.value = 10;
      beacon.value = 11;

      expect(called, equals(2));
    });

    test('undo should revert to the previous value', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0);
      beacon.value = 10; // History: [0, 10]
      beacon.value = 20; // History: [0, 10, 20]

      beacon.undo();

      expect(beacon.value, 10);
    });

    test('redo should revert to the next value after undo', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0);
      beacon.value = 10; // History: [0, 10]
      beacon.value = 20; // History: [0, 10, 20]
      beacon.undo(); // History: [0, <10>, 20]

      beacon.redo(); // History: [0, 10, <20>]

      expect(beacon.value, 20);
    });

    test('should not undo beyond the initial value', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0);
      beacon.value = 10;
      beacon.undo(); // Should stay at initial value

      expect(beacon.value, 0);
    });

    test('should not redo beyond the latest value', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0);
      beacon.value = 10; // History: [0, 10]
      beacon.value = 20; // History: [0, 10, 20]
      beacon.undo(); // History: [0, <10>, 20]
      beacon.redo(); // History: [0, 10, <20>]
      beacon.redo(); // Should stay at latest value

      expect(beacon.value, 20);
    });

    test('should truncate future history if value is set after undo', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0);
      // Set initial values
      beacon.set(1);
      beacon.set(2);
      beacon.set(3); // History: [0, 1, 2, 3]

      // Undo twice, moving back in history
      beacon.undo(); // Current value is 2
      beacon.undo(); // Current value is 1

      // Set a new value after undo
      beacon.set(4); // New history should be [0, 1, 4]

      // Check the length of history and current value
      expect(beacon.value, equals(4));
      expect(beacon.history, equals([0, 1, 4]));
    });

    test('should respect history limit', () {
      var beacon = UndoRedoBeacon<int>(initialValue: 0, historyLimit: 2);
      beacon.value = 10; // History: [0, 10]
      beacon.value = 20; // History: [10, 20]
      beacon.value = 30; // History: [20, 30] (0 should be pushed out)

      beacon.undo();
      beacon.undo(); // Should not be able to undo to 0

      expect(beacon.value, 20);
    });
  });

  group('BufferedCountBeacon', () {
    test('should buffer values until count is reached', () {
      var beacon = Beacon.bufferedCount<int>(3);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);
      beacon.add(3); // This should trigger the buffer to be set

      expect(buffer, equals([1, 2, 3]));
    });

    test('should clear buffer after reaching count threshold', () {
      var beacon = Beacon.bufferedCount<int>(2);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2); // First trigger

      expect(buffer, equals([1, 2]));

      expect(beacon.currentBuffer.value, equals([]));

      beacon.add(3);

      expect(beacon.currentBuffer.value, equals([3]));

      beacon.add(4); // Second trigger

      expect(buffer, equals([3, 4]));
    });

    test('should update currentBuffer', () {
      var beacon = Beacon.bufferedCount<int>(3);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      expect(beacon.currentBuffer.value, equals([1, 2]));

      beacon.add(3); // This should trigger the buffer to be set
      beacon.add(4);

      expect(beacon.currentBuffer.value, equals([4]));

      expect(buffer, equals([1, 2, 3]));
    });

    test('should reset', () {
      var beacon = Beacon.bufferedCount<int>(3);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      beacon.reset();

      expect(beacon.currentBuffer.value, equals([]));
      expect(buffer, equals([]));
    });
  });

  group('BufferedTimeBeacon', () {
    test('should buffer values over a time duration', () async {
      var beacon =
          Beacon.bufferedTime<int>(duration: Duration(milliseconds: 50));
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      await Future.delayed(Duration(milliseconds: 10));

      expect(buffer, equals([]));

      await Future.delayed(Duration(milliseconds: 50));

      expect(buffer, equals([1, 2]));
    });

    test('should reset buffer after time duration', () async {
      var beacon =
          Beacon.bufferedTime<int>(duration: Duration(milliseconds: 30));
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);
      beacon.add(3);
      beacon.add(4);

      await Future.delayed(Duration(milliseconds: 40));

      expect(beacon.currentBuffer.value, equals([]));

      expect(buffer, equals([1, 2, 3, 4]));
    });

    test('should reset', () async {
      var beacon =
          Beacon.bufferedTime<int>(duration: Duration(milliseconds: 30));
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      beacon.reset();

      await Future.delayed(Duration(milliseconds: 40));

      expect(beacon.currentBuffer.value, equals([]));
      expect(buffer, equals([]));
    });
  });

  group('Previous value Tests', () {
    test('should set previous and initial values - writable', () {
      var beacon = Beacon.writable(10);
      beacon.value = 20;
      expect(beacon.previousValue, equals(10));
      beacon.value = 30;
      expect(beacon.previousValue, equals(20));

      beacon.reset();
      expect(beacon.previousValue, equals(30));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - readable', () {
      var beacon = Beacon.readable(10);
      expect(beacon.previousValue, equals(null));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - undoredo', () {
      var beacon = Beacon.undoRedo(10);
      beacon.value = 20;
      expect(beacon.previousValue, equals(10));
      beacon.value = 30;
      expect(beacon.previousValue, equals(20));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - timestamp', () {
      var beacon = Beacon.timestamped(10);
      beacon.set(20);
      expect(beacon.previousValue?.value, equals(10));
      beacon.set(30);
      expect(beacon.previousValue?.value, equals(20));
      expect(beacon.initialValue.value, 10);
    });

    test('should set previous and initial values - throttled', () async {
      var beacon = Beacon.throttled(10, duration: k10ms);
      beacon.set(20);
      expect(beacon.previousValue, equals(10));
      await Future.delayed(k10ms * 1.1);
      beacon.set(30);
      expect(beacon.previousValue, equals(20));
      expect(beacon.initialValue, 10);
    });

    test('should set previous and initial values - filtered', () {
      var beacon = Beacon.lazyFiltered<int>(filter: (p, x) => x > 5);
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

    test('should set previous and initial values - derived', () {
      var count = Beacon.writable(0);
      var beacon = Beacon.derived(() => count.value * 2);
      count.set(1);
      expect(beacon.previousValue, equals(0));
      count.set(5);
      expect(beacon.previousValue, equals(2));
      expect(beacon.initialValue, 0);
    });

    test('should set previous and initial values - derivedFuture', () async {
      var count = Beacon.writable(0);
      var beacon = Beacon.derivedFuture(() async => count.value * 2);

      await Future.delayed(k10ms * 10);
      count.set(1);

      await Future.delayed(k10ms * 10);
      expect(beacon.previousValue?.unwrapValue(), equals(0));
      count.set(5);

      await Future.delayed(k10ms * 10);
      expect(beacon.previousValue?.unwrapValue(), equals(2));

      count.set(10);
      expect(beacon.lastData, equals(10));

      await Future.delayed(k10ms * 10);
      expect(beacon.previousValue?.unwrapValue(), equals(10));
      expect(beacon.value.unwrapValue(), equals(20));

      expect(beacon.initialValue, isA<AsyncLoading<int>>());
    });

    test('should set previous and initial values - debounced', () async {
      var beacon = Beacon.debounced<int>(5, duration: k10ms);

      beacon.set(10);
      await Future.delayed(k10ms * 1.1);
      expect(beacon.previousValue, equals(5));

      beacon.set(15);
      await Future.delayed(k10ms * 1.1);
      expect(beacon.previousValue, equals(10));

      expect(beacon.initialValue, equals(5));
    });

    test('should set previous and initial values - buffered', () async {
      var beacon = Beacon.bufferedCount<int>(2);

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
