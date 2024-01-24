import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should run immediately', () {
    final beacon = Beacon.writable(1);
    var effectCount = 0;

    final _ = Beacon.derived(() {
      effectCount++;
      return beacon();
    });

    expect(effectCount, 1);

    beacon.increment();

    expect(effectCount, 2);
  });

  test('should be correct derived value upon initialization', () {
    final beacon = Beacon.writable<int>(10);
    final derivedBeacon = Beacon.derived(() => beacon.value * 2);

    expect(derivedBeacon.value, equals(20));
  });

  test('should update derived value when dependency changes', () {
    final beacon = Beacon.writable<int>(10);
    final derivedBeacon = Beacon.derived(() => beacon.value * 2);

    beacon.value = 20;
    expect(derivedBeacon.value, equals(40));
  });

  test('should run once per update', () {
    final beacon = Beacon.writable<int>(10);
    var called = 0;
    final derivedBeacon = Beacon.derived(() {
      called++;
      return beacon.value * 2;
    });

    beacon.value = 30;
    expect(derivedBeacon.value, equals(60));

    expect(called, equals(2));
  });

  test('should recompute when watching multiple dependencies', () {
    final beacon1 = Beacon.writable<int>(10);
    final beacon2 = Beacon.writable<int>(20);
    final derivedBeacon = Beacon.derived(() => beacon1.value + beacon2.value);

    beacon1.value = 15;
    expect(derivedBeacon.value, equals(35));

    beacon2.value = 25;
    expect(derivedBeacon.value, equals(40));
  });

  test('should throw when derived computation mutates', () {
    final beacon1 = Beacon.writable<int>(10);

    try {
      Beacon.derived(() => beacon1.value++);
    } catch (e) {
      expect(e, isA<CircularDependencyException>());
    }
  });

  test('should not watch new beacon conditionally', () {
    final num1 = Beacon.writable<int>(10);
    final num2 = Beacon.writable<int>(20);

    final derivedBeacon = Beacon.derived(
      () {
        if (num2().isEven) return num2();
        return num1.value + num2.value;
      },
      supportConditional: false,
    );

    expect(derivedBeacon(), 20);

    // should not trigger recompute as it wasn't accessed on first run
    num1.value = 15;

    expect(derivedBeacon.value, 20);
  });
}
