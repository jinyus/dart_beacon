import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

//rm: 2 irrelevant tests
void main() {
  test('should not run until accessed', () async {
    final beacon = Beacon.writable(1);
    var effectCount = 0;

    final d = Beacon.derived(() {
      effectCount++;
      return beacon();
    });

    BeaconScheduler.flush();

    expect(effectCount, 0);

    beacon.increment();

    BeaconScheduler.flush();

    expect(effectCount, 0);

    expect(d(), 2);
    expect(effectCount, 1);

    beacon.increment();

    BeaconScheduler.flush();

    expect(effectCount, 1);

    expect(d(), 3);
    expect(effectCount, 2);
  });

  test('should be correct derived value upon initialization', () {
    final beacon = Beacon.writable<int>(10);
    final derivedBeacon = Beacon.derived(() => beacon.value * 2);

    expect(derivedBeacon.value, 20);
  });

  test('should update derived value when dependency changes', () {
    final beacon = Beacon.writable<int>(10);
    final derivedBeacon = Beacon.derived(() => beacon.value * 2);

    beacon.value = 20;
    expect(derivedBeacon.value, 40);
  });

  test('should run once per update', () {
    final beacon = Beacon.writable<int>(10);
    var called = 0;
    final derivedBeacon = Beacon.derived(() {
      called++;
      return beacon.value * 2;
    });

    beacon.value = 30;
    expect(derivedBeacon.value, 60);

    expect(called, 1);
  });

  test('should recompute when watching multiple dependencies', () {
    final beacon1 = Beacon.writable<int>(10);
    final beacon2 = Beacon.writable<int>(20);
    final derivedBeacon = Beacon.derived(() => beacon1.value + beacon2.value);

    beacon1.value = 15;
    expect(derivedBeacon.value, 35);

    beacon2.value = 25;
    expect(derivedBeacon.value, 40);
  });

  test('should ignore when derived computation mutates', () {
    final beacon1 = Beacon.writable<int>(10);

    final d = Beacon.derived(() => beacon1.value++);

    expect(d(), 10);

    beacon1.value = 20;

    expect(d(), 20);
  });

  test('should stop watching dependencies when it has no more watchers',
      () async {
    final num1 = Beacon.writable<int>(10);
    final num2 = Beacon.writable<int>(20);

    final derivedBeacon = Beacon.derived(() => num1.value + num2.value);

    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 0);
    expect(derivedBeacon.listenersCount, 0);

    final unsub = Beacon.effect(() => derivedBeacon.value);

    BeaconScheduler.flush();

    expect(derivedBeacon.listenersCount, 1);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    unsub();

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    // should start listening again when value is accessed
    num1.value = 15;

    expect(derivedBeacon.value, 35);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    // should stop listening again when it has no more listeners

    final unsub2 = Beacon.effect(() => derivedBeacon.value);

    BeaconScheduler.flush();

    expect(derivedBeacon.listenersCount, 1);

    unsub2();

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    // should start listening again when value is accessed
    num1.value = 20;

    expect(derivedBeacon.peek(), 40);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);
  });

  test('should conditionally stop watching beacons', () async {
    final a = Beacon.writable(1, name: 'a');
    final b = Beacon.writable(2, name: 'b');
    final c = Beacon.writable(2, name: 'c');
    final guard = Beacon.writable(true, name: 'guard');
    var ran = 0;
    var notified = 0;

    final d = Beacon.derived(
      () {
        ran++;
        if (guard.value) {
          return a() + b();
        }
        return c();
      },
      name: 'derived',
    );

    final dispose = d.subscribe((_) => notified++);

    BeaconScheduler.flush();

    expect(ran, 1);
    expect(notified, 1);

    expect(a.listenersCount, 1);
    expect(b.listenersCount, 1);
    expect(c.listenersCount, 0);

    a.value = 3;

    BeaconScheduler.flush();

    expect(ran, 2);
    expect(notified, 2);
    expect(a.listenersCount, 1);
    expect(b.listenersCount, 1);
    expect(c.listenersCount, 0);

    guard.value = false;

    BeaconScheduler.flush();

    expect(ran, 3);
    expect(notified, 3);
    expect(a.listenersCount, 0);
    expect(b.listenersCount, 0);
    expect(c.listenersCount, 1);

    b.value = 4;

    BeaconScheduler.flush();

    expect(ran, 3);
    expect(notified, 3);

    c.value = 5;

    BeaconScheduler.flush();

    expect(ran, 4);
    expect(notified, 4);

    dispose();

    BeaconScheduler.flush();

    expect(d.listenersCount, 0);
    expect(a.listenersCount, 0);
    expect(b.listenersCount, 0);
    expect(c.listenersCount, 1);
    expect(guard.listenersCount, 1);
    expect(ran, 4);
    expect(notified, 4);

    // derived shouldn't run because it's not being listened to
    guard.value = true;

    BeaconScheduler.flush();

    expect(ran, 4);
    expect(notified, 4);
  });

  // disabled for performance reasons. This is a rare case and it's not worth
  // the performance hit. Consumers are marked dirty on the first run so marking
  // them dirty again is cheap and basically a no-op.
  // test('should create single dependency if accessed multiple times', () {
  //   final a = Beacon.writable(1);
  //   var ran = 0;
  //   final d = Beacon.derived(() {
  //     ran++;
  //     a.value;
  //     a.value;
  //     return a.value;
  //   });

  //   expect(ran, 0);
  //   expect(d.value, 1);
  //   expect(ran, 1);
  //   expect(a.listenersCount, 1);
  // });
}
