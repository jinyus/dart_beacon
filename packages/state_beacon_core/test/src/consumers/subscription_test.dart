import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('subscription to beacon should run until disposed', () async {
    final a = Beacon.writable(0);
    var called = 0;

    final dispose = a.subscribe((_) => called++);

    await BeaconScheduler.settle();
    expect(called, 1);

    a.value = 2;
    await BeaconScheduler.settle();
    expect(called, 2);

    a.value = 2; // no change
    await BeaconScheduler.settle();
    expect(called, 2);

    a.set(2, force: true); // force change
    await BeaconScheduler.settle();
    expect(called, 3);

    dispose();
    a.value = 10;
    await BeaconScheduler.settle();
    expect(called, 3);
  });

  test('subscription to beacon should run until disposed(sync)', () async {
    // BeaconObserver.instance = LoggingObserver();
    final a = Beacon.writable(0, name: 'a');
    var called = 0;

    final dispose = a.subscribe((_) => called++, synchronous: true);

    expect(called, 1);

    a.value = 2;
    expect(called, 2);

    a.value = 2; // no change
    expect(called, 2);

    a.set(2, force: true); // force change
    expect(called, 3);

    dispose();
    a.value = 10;
    expect(called, 3);
  });

  test('subscription to derived should run  until disposed', () async {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    final c = Beacon.derived(() => b() * 2, name: 'c');

    var called = 0;

    final dispose = c.subscribe((_) => called++);

    await BeaconScheduler.settle();
    expect(called, 1);

    a.value = 2;
    await BeaconScheduler.settle();
    expect(called, 2);

    a.value = 2; // no change
    await BeaconScheduler.settle();
    expect(called, 2);

    // a.set(2, force: true); // force change
    // await BeaconScheduler.settle();
    // expect(called, 3);

    dispose();
    a.value = 10;
    await BeaconScheduler.settle();
    expect(called, 2);
  });

  test('subscription to derived should run  until disposed(sync)', () async {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    final c = Beacon.derived(() => b() * 2, name: 'c');

    var called = 0;

    final dispose = c.subscribe((_) => called++, synchronous: true);

    expect(called, 1);

    a.value = 2;

    expect(called, 2);

    a.value = 2; // no change

    expect(called, 2);

    // a.set(2, force: true); // force change
    // expect(called, 3);

    dispose();
    a.value = 10;

    expect(called, 2);
  });

  test('subscription to beacon should run until disposed when startNow=false',
      () async {
    final a = Beacon.writable(0);
    var called = 0;

    final dispose = a.subscribe((_) => called++, startNow: false);

    await BeaconScheduler.settle();
    expect(called, 0);

    a.value = 2;
    await BeaconScheduler.settle();
    expect(called, 1);

    a.value = 2; // no change
    await BeaconScheduler.settle();
    expect(called, 1);

    a.set(2, force: true); // force change
    await BeaconScheduler.settle();
    expect(called, 2);

    dispose();
    a.value = 10;
    await BeaconScheduler.settle();
    expect(called, 2);
  });

  test(
    'subscription to beacon should run until'
    ' disposed when startNow=false (sync)',
    () async {
      final a = Beacon.writable(0);
      var called = 0;

      final dispose = a.subscribe(
        (_) => called++,
        startNow: false,
        synchronous: true,
      );

      expect(called, 0);

      a.value = 2;
      expect(called, 1);

      a.value = 2; // no change
      expect(called, 1);

      a.set(2, force: true); // force change
      expect(called, 2);

      dispose();
      a.value = 10;
      expect(called, 2);
    },
  );

  test('subscription to derived should run  until disposed when startNow=false',
      () async {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    final c = Beacon.derived(() => b() * 2, name: 'c');

    var called = 0;

    final dispose = c.subscribe((_) => called++, startNow: false);

    await BeaconScheduler.settle();
    expect(called, 0);

    a.value = 2;
    await BeaconScheduler.settle(k10ms);
    expect(called, 1);

    a.value = 2; // no change
    await BeaconScheduler.settle();
    expect(called, 1);

    a.set(2, force: true); // force change
    await BeaconScheduler.settle();
    expect(called, 1); // propagation won't make it to c

    dispose();
    a.value = 10;
    await BeaconScheduler.settle();
    expect(called, 1);
  });

  test(
    'subscription to derived should run'
    ' until disposed when startNow=false(sync)',
    () async {
      final a = Beacon.writable(0, name: 'a');
      final b = Beacon.derived(() => a() * 2, name: 'b');
      final c = Beacon.derived(() => b() * 2, name: 'c');

      var called = 0;

      final dispose = c.subscribe(
        (_) => called++,
        startNow: false,
        synchronous: true,
      );

      expect(called, 0);

      a.value = 2;

      expect(called, 1);

      a.value = 2; // no change

      expect(called, 1);

      a.set(2, force: true); // force change

      expect(called, 1); // propagation won't make it to c

      dispose();
      a.value = 10;

      expect(called, 1);
    },
  );
}
