import 'package:test/test.dart';
import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

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

  test('should not watch new beacon conditionally', () {
    var num1 = Beacon.writable<int>(10);
    var num2 = Beacon.writable<int>(20);

    var derivedBeacon = Beacon.derived(
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
