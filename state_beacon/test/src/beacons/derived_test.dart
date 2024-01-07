import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should run immediately', () {
    final beacon = Beacon.writable(1);
    var effectCount = 0;

    final _ = Beacon.derived(() {
      effectCount++;
      return beacon.value;
    });

    expect(effectCount, 1);

    beacon.increment();

    expect(effectCount, 2);
  });

  test('should not run immediately', () {
    final beacon = Beacon.writable(1);
    var effectCount = 0;

    final derived = Beacon.derived(() {
      effectCount++;
      return beacon.peek();
    }, manualStart: true);

    expect(effectCount, 0);

    beacon.increment();

    expect(effectCount, 0);

    derived.start();

    expect(effectCount, 1);
  });

  test('should be correct derived value upon initialization', () {
    var beacon = Beacon.writable<int>(10);
    var derivedBeacon = Beacon.derived(() => beacon.value * 2);

    expect(derivedBeacon.value, equals(20));
  });

  test('should update derived value when dependency changes', () {
    var beacon = Beacon.writable<int>(10);
    var derivedBeacon = Beacon.derived(() => beacon.value * 2);

    beacon.value = 20;
    expect(derivedBeacon.value, equals(40));
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
}
