import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should conditionally stop listening to beacons', () async {
    final name = Beacon.writable('Bob', name: 'name');
    final age = Beacon.writable(20, name: 'age');
    final college = Beacon.writable('MIT', name: 'college');

    final buff = <String>[];

    Beacon.effect(
      () {
        var msg = '${name()} is ${age()} years old';

        if (age.value > 21) {
          msg += ' and can go to ${college.value}';
        }

        buff.add(msg);
      },
      name: 'effect',
    );

    await BeaconScheduler.settle();

    name.value = 'Alice';
    await BeaconScheduler.settle();
    age.value = 21;
    await BeaconScheduler.settle();
    college.value = 'Stanford'; // Should not run because age is less than 21
    await BeaconScheduler.settle();
    age.value = 22;
    await BeaconScheduler.settle();
    college.value = 'Harvard';
    await BeaconScheduler.settle();
    age.value = 18;
    await BeaconScheduler.settle();

    // Should stop listening to college beacon because age is less than 21
    college.value = 'Yale';
    await BeaconScheduler.settle();

    // if (isSynchronousMode) return;

    expect(buff, [
      'Bob is 20 years old',
      'Alice is 20 years old',
      'Alice is 21 years old',
      'Alice is 22 years old and can go to Stanford',
      'Alice is 22 years old and can go to Harvard',
      'Alice is 18 years old',
    ]);
  });

  // test('should never listen to beacons not accessed on first run', () async {
  //   final name = Beacon.writable('Bob', name: 'name');
  //   final age = Beacon.writable(20, name: 'age');
  //   final college = Beacon.writable('MIT', name: 'college');

  //   final buff = Beacon.bufferedTime<String>(duration: k10ms);
  //   Beacon.effect(
  //     () {
  //       // ignore: unused_local_variable
  //       var msg = '${name.value} is ${age.value} years old';

  //       if (age.value > 21) {
  //         // a change to college should not trigger this effect
  //         // as it is not accessed in the first run
  //         msg += ' and can go to ${college.value}';
  //       }

  //       buff.add(msg);
  //     },
  //     supportConditional: false,
  //   );

  //   name.value = 'Alice';
  //   age.value = 21;
  //   college.value = 'Stanford';
  //   age.value = 22;
  //   college.value = 'Harvard';
  //   age.value = 18;

  //   college.value = 'Yale';

  //   await delay(k10ms * 2);

  //   expect(buff.value, [
  //     'Bob is 20 years old',
  //     'Alice is 20 years old',
  //     'Alice is 21 years old',
  //     'Alice is 22 years old and can go to Stanford',
  //     'Alice is 18 years old',
  //   ]);
  // });

  test('should run when a dependency changes', () async {
    final beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon(); // Dependency
    });

    await BeaconScheduler.settle();

    // Should be true immediately after createEffect
    expect(effectCalled, isTrue);

    effectCalled = false; // Resetting for the next check
    beacon.value = 20;
    await BeaconScheduler.settle();
    expect(effectCalled, isTrue);
  });

  test('should not run when dependencies are unchanged', () async {
    final beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon.value; // Dependency
    });
    await BeaconScheduler.settle();

    // Should be true immediately after createEffect
    expect(effectCalled, isTrue);

    effectCalled = false; // Resetting for the next check
    beacon.value = 10;

    await BeaconScheduler.settle();

    // Not changing the beacon value
    expect(effectCalled, isFalse);
  });

  test('should run when any of its multiple dependencies change', () async {
    final beacon1 = Beacon.writable<int>(10);
    final beacon2 = Beacon.writable<int>(20);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon1.value;
      beacon2(); // Multiple dependencies
    });

    await BeaconScheduler.settle();

    beacon1.value = 15; // Changing one of the dependencies
    expect(effectCalled, isTrue);

    effectCalled = false; // Resetting for the next check
    beacon2.value = 25; // Changing the other dependency
    await BeaconScheduler.settle();
    expect(effectCalled, isTrue);
  });

  test('should run immediately upon creation', () async {
    final beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon.value;
    });

    await BeaconScheduler.settle();

    // Should be true immediately after createEffect
    expect(effectCalled, isTrue);
  });

  test('should cancel the effect', () async {
    final beacon = Beacon.writable(10);
    var effectCalled = 0;

    final cancel = Beacon.effect(() {
      effectCalled++;
      beacon.value;
    });

    await BeaconScheduler.settle();

    expect(beacon.listenersCount, 1);
    cancel();
    expect(effectCalled, 1);
    expect(beacon.listenersCount, 0);

    beacon.value = 20;
    await BeaconScheduler.settle();
    expect(effectCalled, 1);
  });

  test('should not run when effect mutates its dependency', () async {
    final a = Beacon.writable<int>(10, name: 'a');
    var called = 0;
    Beacon.effect(() {
      a.value++;
      called++;
    });

    await BeaconScheduler.settle();
    expect(called, 1);

    a.value = 20;

    await BeaconScheduler.settle();
    expect(a.value, 21);
    expect(called, 2);
  });

  test('should dispose sub effects', () async {
    final a = Beacon.writable<int>(10, name: 'a');
    final b = Beacon.writable<int>(20, name: 'b');
    final c = Beacon.writable<int>(30, name: 'c');
    var effectCalled = 0;
    var effectCalled2 = 0;
    var effectCalled3 = 0;

    final dispose = Beacon.effect(
      () {
        effectCalled++;
        a.value;

        return Beacon.effect(
          () {
            effectCalled2++;
            b.value;

            return Beacon.effect(
              () {
                effectCalled3++;
                c.value;
              },
              name: 'e3',
            );
          },
          name: 'e2',
        );
      },
      name: 'e1',
    );

    await BeaconScheduler.settle();

    a.value = 15;

    await BeaconScheduler.settle();
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    dispose();

    b.value = 25;

    await BeaconScheduler.settle();
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);
  });

  // test('should dispose sub effects when supportConditional is false', () {
  //   final beacon1 = Beacon.writable<int>(10, name: 'beacon1');
  //   final beacon2 = Beacon.writable<int>(20, name: 'beacon2');
  //   final beacon3 = Beacon.writable<int>(30, name: 'beacon3');
  //   var effectCalled = 0;
  //   var effectCalled2 = 0;
  //   var effectCalled3 = 0;

  //   final dispose = Beacon.effect(
  //     () {
  //       effectCalled++;
  //       beacon1.value;

  //       return Beacon.effect(
  //         () {
  //           effectCalled2++;
  //           beacon2.value;

  //           return Beacon.effect(() {
  //             effectCalled3++;
  //             beacon3.value;
  //           });
  //         },
  //         supportConditional: false,
  //       );
  //     },
  //     supportConditional: false,
  //   );

  //   beacon1.value = 15;
  //   expect(effectCalled, 2);
  //   expect(effectCalled2, 2);
  //   expect(effectCalled3, 2);

  //   dispose();

  //   beacon2.value = 25;
  //   expect(effectCalled, 2);
  //   expect(effectCalled2, 2);
  //   expect(effectCalled3, 2);
  // });

  test('should not watch beacons accessed in child effects', () async {
    final a = Beacon.writable<int>(10, name: 'a');
    final b = Beacon.writable<int>(20, name: 'b');
    final c = Beacon.writable<int>(30, name: 'c');
    var effectCalled = 0;
    var effectCalled2 = 0;
    var effectCalled3 = 0;

    Beacon.effect(() {
      effectCalled++;
      a.value;

      return Beacon.effect(() {
        effectCalled2++;
        b.value;

        return Beacon.effect(() {
          effectCalled3++;
          c.value;
        });
      });
    });

    await BeaconScheduler.settle();

    a.value = 15;

    await BeaconScheduler.settle();
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    b.value = 25;

    await BeaconScheduler.settle();
    expect(effectCalled, 2);
    expect(effectCalled2, 3);
    expect(effectCalled3, 3);

    c.value = 35;

    await BeaconScheduler.settle();
    expect(effectCalled, 2);
    expect(effectCalled2, 3);
    expect(effectCalled3, 4);
  });

  test('should conditionally stop watching beacons', () async {
    // BeaconObserver.instance = LoggingObserver();
    final a = Beacon.writable(1, name: 'a');
    final b = Beacon.writable(2, name: 'b');
    final c = Beacon.writable(2, name: 'c');
    final guard = Beacon.writable(true, name: 'guard');
    var ran = 0;

    Beacon.effect(
      () {
        ran++;
        if (guard.value) {
          a();
          b();
        } else {
          c();
        }
      },
      name: 'effect',
    );

    await BeaconScheduler.settle();

    expect(ran, 1);
    expect(a.listenersCount, 1);
    expect(b.listenersCount, 1);
    expect(c.listenersCount, 0);

    a.value = 3;

    await BeaconScheduler.settle();

    expect(ran, 2);
    expect(a.listenersCount, 1);
    expect(b.listenersCount, 1);
    expect(c.listenersCount, 0);

    guard.value = false;

    await BeaconScheduler.settle();

    expect(ran, 3);
    expect(a.listenersCount, 0);
    expect(b.listenersCount, 0);
    expect(c.listenersCount, 1);

    b.value = 4;

    await BeaconScheduler.settle();

    expect(ran, 3);

    c.value = 5;

    await BeaconScheduler.settle();

    expect(ran, 4);
  });

  test('should not cause stack overflow when effect mutate its dep', () {
    // BeaconObserver.instance = LoggingObserver();
    final a = Beacon.writable<int>(10, name: 'a');
    var called = 0;

    Beacon.effect(() {
      a.value++;
      called++;
    });

    BeaconScheduler.flush();

    expect(called, 1);
    expect(a.value, 11);

    a.value = 20;

    BeaconScheduler.flush();

    expect(a.value, 21);
    expect(called, 2);
  });
}
