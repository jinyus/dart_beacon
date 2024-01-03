import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../common.dart';

void main() {
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
