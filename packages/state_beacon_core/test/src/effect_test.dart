import 'package:test/test.dart';
import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

import '../common.dart';

void main() {
  test('should conditionally stop listening to beacons', () async {
    final name = Beacon.writable("Bob", name: 'name');
    final age = Beacon.writable(20, name: 'age');
    final college = Beacon.writable("MIT", name: 'college');

    final buff = Beacon.bufferedTime<String>(duration: k10ms);

    Beacon.effect(() {
      var msg = '${name()} is ${age()} years old';

      if (age.value > 21) {
        msg += ' and can go to ${college.value}';
      }

      buff.add(msg);
    });

    name.value = "Alice";
    age.value = 21;
    college.value = "Stanford"; // Should not run because age is less than 21
    age.value = 22;
    college.value = "Harvard";
    age.value = 18;

    // Should stop listening to college beacon because age is less than 21
    college.value = "Yale";

    await Future<void>.delayed(k10ms * 2);

    expect(buff.value, [
      'Bob is 20 years old',
      'Alice is 20 years old',
      'Alice is 21 years old',
      'Alice is 22 years old and can go to Stanford',
      'Alice is 22 years old and can go to Harvard',
      'Alice is 18 years old',
    ]);
  });

  test('should never listen to beacons not accessed on first run', () async {
    final name = Beacon.writable("Bob", name: 'name');
    final age = Beacon.writable(20, name: 'age');
    final college = Beacon.writable("MIT", name: 'college');

    final buff = Beacon.bufferedTime<String>(duration: k10ms);
    Beacon.effect(
      () {
        // ignore: unused_local_variable
        var msg = '${name.value} is ${age.value} years old';

        if (age.value > 21) {
          // a change to college should not trigger this effect
          // as it is not accessed in the first run
          msg += ' and can go to ${college.value}';
        }

        buff.add(msg);
      },
      supportConditional: false,
    );

    name.value = "Alice";
    age.value = 21;
    college.value = "Stanford";
    age.value = 22;
    college.value = "Harvard";
    age.value = 18;

    college.value = "Yale";

    await Future<void>.delayed(k10ms * 2);

    expect(buff.value, [
      'Bob is 20 years old',
      'Alice is 20 years old',
      'Alice is 21 years old',
      'Alice is 22 years old and can go to Stanford',
      'Alice is 18 years old',
    ]);
  });

  test('should run when a dependency changes', () {
    var beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon(); // Dependency
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

    Beacon.effect(() {
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

    Beacon.effect(() {
      effectCalled = true;
      beacon1.value;
      beacon2(); // Multiple dependencies
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

    Beacon.effect(() {
      effectCalled = true;
      beacon.value;
    });

    // Should be true immediately after createEffect
    expect(effectCalled, isTrue);
  });

  test('should cancel the effect', () {
    var beacon = Beacon.writable(10);
    var effectCalled = 0;

    var cancel = Beacon.effect(() {
      effectCalled++;
      beacon.value;
    });

    expect(beacon.listenersCount, 1);
    cancel();
    expect(effectCalled, 1);
    expect(beacon.listenersCount, 0);

    beacon.value = 20;
    expect(effectCalled, 1);
  });

  test('should throw when effect mutates its dependency', () {
    var beacon1 = Beacon.writable<int>(10);

    try {
      Beacon.effect(() {
        Beacon.batch(() {
          beacon1.value++;
        });
      });
    } catch (e) {
      expect(e, isA<CircularDependencyException>());
      expect(e.toString(), contains('batch'));
    }
  });

  test('should dispose sub effects', () {
    var beacon1 = Beacon.writable<int>(10, name: 'beacon1');
    var beacon2 = Beacon.writable<int>(20, name: 'beacon2');
    var beacon3 = Beacon.writable<int>(30, name: 'beacon3');
    var effectCalled = 0;
    var effectCalled2 = 0;
    var effectCalled3 = 0;

    final dispose = Beacon.effect(() {
      effectCalled++;
      beacon1.value;

      return Beacon.effect(() {
        effectCalled2++;
        beacon2.value;

        return Beacon.effect(() {
          effectCalled3++;
          beacon3.value;
        });
      });
    });

    beacon1.value = 15;
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    dispose();

    beacon2.value = 25;
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);
  });

  test('should dispose sub effects when supportConditional is false', () {
    var beacon1 = Beacon.writable<int>(10, name: 'beacon1');
    var beacon2 = Beacon.writable<int>(20, name: 'beacon2');
    var beacon3 = Beacon.writable<int>(30, name: 'beacon3');
    var effectCalled = 0;
    var effectCalled2 = 0;
    var effectCalled3 = 0;

    final dispose = Beacon.effect(() {
      effectCalled++;
      beacon1.value;

      return Beacon.effect(() {
        effectCalled2++;
        beacon2.value;

        return Beacon.effect(() {
          effectCalled3++;
          beacon3.value;
        });
      }, supportConditional: false);
    }, supportConditional: false);

    beacon1.value = 15;
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    dispose();

    beacon2.value = 25;
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);
  });

  test('should not watch beacons accessed in child effects', () {
    var beacon1 = Beacon.writable<int>(10, name: 'beacon1');
    var beacon2 = Beacon.writable<int>(20, name: 'beacon2');
    var beacon3 = Beacon.writable<int>(30, name: 'beacon3');
    var effectCalled = 0;
    var effectCalled2 = 0;
    var effectCalled3 = 0;

    Beacon.effect(() {
      effectCalled++;
      beacon1.value;

      return Beacon.effect(() {
        effectCalled2++;
        beacon2.value;

        return Beacon.effect(() {
          effectCalled3++;
          beacon3.value;
        });
      });
    });

    beacon1.value = 15;
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    beacon2.value = 25;
    expect(effectCalled, 2);
    expect(effectCalled2, 3);
    expect(effectCalled3, 3);

    beacon3.value = 35;
    expect(effectCalled, 2);
    expect(effectCalled2, 3);
    expect(effectCalled3, 4);
  });
}
