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

    BeaconScheduler.flush();

    name.value = 'Alice';
    BeaconScheduler.flush();
    age.value = 21;
    BeaconScheduler.flush();
    college.value = 'Stanford'; // Should not run because age is less than 21
    BeaconScheduler.flush();
    age.value = 22;
    BeaconScheduler.flush();
    college.value = 'Harvard';
    BeaconScheduler.flush();
    age.value = 18;
    BeaconScheduler.flush();

    // Should stop listening to college beacon because age is less than 21
    college.value = 'Yale';
    BeaconScheduler.flush();

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

  test('should run when a dependency changes', () async {
    final beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon(); // Dependency
    });

    BeaconScheduler.flush();

    // Should be true immediately after createEffect
    expect(effectCalled, isTrue);

    effectCalled = false; // Resetting for the next check
    beacon.value = 20;
    BeaconScheduler.flush();
    expect(effectCalled, isTrue);
  });

  test('should not run when dependencies are unchanged', () async {
    final beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon.value; // Dependency
    });
    BeaconScheduler.flush();

    // Should be true immediately after createEffect
    expect(effectCalled, isTrue);

    effectCalled = false; // Resetting for the next check
    beacon.value = 10;

    BeaconScheduler.flush();

    // Not changing the beacon value
    expect(effectCalled, isFalse);
  });

  test('should run when any of its multiple dependencies change', () {
    final beacon1 = Beacon.writable<int>(10);
    final beacon2 = Beacon.writable<int>(20);
    var ran = 0;

    Beacon.effect(() {
      ran++;
      beacon1.value;
      beacon2();
    });

    BeaconScheduler.flush();

    expect(ran, 1);

    beacon1.value = 15;
    BeaconScheduler.flush();
    expect(ran, 2);

    beacon2.value = 25;
    BeaconScheduler.flush();
    expect(ran, 3);
  });

  test('should run immediately upon creation', () async {
    final beacon = Beacon.writable<int>(10);
    var effectCalled = false;

    Beacon.effect(() {
      effectCalled = true;
      beacon.value;
    });

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

    expect(beacon.listenersCount, 1);
    cancel();
    expect(effectCalled, 1);
    expect(beacon.listenersCount, 0);

    beacon.value = 20;
    BeaconScheduler.flush();
    expect(effectCalled, 1);
  });

  test('should not run when effect mutates its dependency', () async {
    final a = Beacon.writable<int>(10, name: 'a');
    var called = 0;
    Beacon.effect(() {
      a.value++;
      called++;
    });

    BeaconScheduler.flush();
    expect(called, 1);

    a.value = 20;

    BeaconScheduler.flush();
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

    BeaconScheduler.flush();

    a.value = 15;

    BeaconScheduler.flush();
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    dispose();

    b.value = 25;

    BeaconScheduler.flush();
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    expect(a.listenersCount, 0);
    expect(b.listenersCount, 0);
    expect(c.listenersCount, 0);
  });

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

    BeaconScheduler.flush();

    a.value = 15;

    BeaconScheduler.flush();
    expect(effectCalled, 2);
    expect(effectCalled2, 2);
    expect(effectCalled3, 2);

    b.value = 25;

    BeaconScheduler.flush();
    expect(effectCalled, 2);
    expect(effectCalled2, 3);
    expect(effectCalled3, 3);

    c.value = 35;

    BeaconScheduler.flush();
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

    BeaconScheduler.flush();

    expect(ran, 1);
    expect(a.listenersCount, 1);
    expect(b.listenersCount, 1);
    expect(c.listenersCount, 0);

    a.value = 3;

    BeaconScheduler.flush();

    expect(ran, 2);
    expect(a.listenersCount, 1);
    expect(b.listenersCount, 1);
    expect(c.listenersCount, 0);

    guard.value = false;

    BeaconScheduler.flush();

    expect(ran, 3);
    expect(a.listenersCount, 0);
    expect(b.listenersCount, 0);
    expect(c.listenersCount, 1);

    b.value = 4;

    BeaconScheduler.flush();

    expect(ran, 3);

    c.value = 5;

    BeaconScheduler.flush();

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

  test('should create single dependency if accessed multiple times', () {
    final a = Beacon.writable(1);
    var ran = 0;

    Beacon.effect(() {
      ran++;
      a.value;
      a.value;
    });

    expect(ran, 0);
    BeaconScheduler.flush();
    expect(ran, 1);
    expect(a.listenersCount, 1);
  });

  test('should call clean up function when re-executing/disposed', () {
    final a = Beacon.writable(1);
    var ran = 0;
    var cleanUpCalled = 0;

    final dispose = Beacon.effect(() {
      ran++;
      a.value;
      return () {
        cleanUpCalled++;
      };
    });

    expect(ran, 0);
    BeaconScheduler.flush();
    expect(ran, 1);
    expect(a.listenersCount, 1);

    a.value = 2;
    BeaconScheduler.flush();
    expect(ran, 2);
    expect(cleanUpCalled, 1);

    dispose();
    expect(a.listenersCount, 0);
    expect(cleanUpCalled, 2);
  });

  test('should run when derived beacon dependency changes', () {
    final a = Beacon.writable(1);
    final b = Beacon.derived(() => a() + 1);
    var ran = 0;

    Beacon.effect(() {
      ran++;
      b.value;
    });

    BeaconScheduler.flush();
    expect(ran, 1);

    a.value = 3;
    BeaconScheduler.flush();
    expect(ran, 2);

    a.value = 4;
    BeaconScheduler.flush();
    expect(ran, 3);
  });
}
