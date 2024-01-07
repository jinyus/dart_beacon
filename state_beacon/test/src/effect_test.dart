import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
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

  test('should continue listening to unused beacons', () {
    final name = Beacon.writable("Bob");
    final age = Beacon.writable(20);
    final college = Beacon.writable("MIT");

    var called = 0;
    Beacon.createEffect(
      () {
        called++;
        // ignore: unused_local_variable
        var msg = '${name.value} is ${age.value} years old';

        if (age.value > 21) {
          msg += ' and can go to ${college.value}';
        }

        // print(msg);
      },
      supportConditional: false,
    );

    name.value = "Alice";
    age.value = 21;
    college.value = "Stanford";
    age.value = 22;
    college.value = "Harvard";
    age.value = 18;

    // Should still listen to college beacon even if age is less than 21
    college.value = "Yale";

    expect(called, equals(7));
  });

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
}
