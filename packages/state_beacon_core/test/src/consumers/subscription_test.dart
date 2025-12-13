import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('subscription to beacon should run until disposed', () async {
    final a = Beacon.writable(0);
    var called = 0;

    final dispose = a.subscribe((_) => called++);

    BeaconScheduler.flush();
    expect(called, 1);

    a.value = 2;
    BeaconScheduler.flush();
    expect(called, 2);

    a.value = 2; // no change
    BeaconScheduler.flush();
    expect(called, 2);

    a.set(2, force: true); // force change
    BeaconScheduler.flush();
    expect(called, 3);

    dispose();
    a.value = 10;
    BeaconScheduler.flush();
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

  test('subscription to beacon should run until disposed when startNow=false',
      () async {
    final a = Beacon.writable(0);
    var called = 0;

    final dispose = a.subscribe((_) => called++, startNow: false);

    BeaconScheduler.flush();
    expect(called, 0);

    a.value = 2;
    BeaconScheduler.flush();
    expect(called, 1);

    a.value = 2; // no change
    BeaconScheduler.flush();
    expect(called, 1);

    a.set(2, force: true); // force change
    BeaconScheduler.flush();
    expect(called, 2);

    dispose();
    a.value = 10;
    BeaconScheduler.flush();
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

  test('subscription to derived should run until disposed', () async {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    final c = Beacon.derived(() => b() * 2, name: 'c');

    var called = 0;

    final dispose = c.subscribe((_) => called++);

    BeaconScheduler.flush();
    expect(called, 1);

    a.value = 2;
    BeaconScheduler.flush();
    expect(called, 2);

    a.value = 2; // no change
    BeaconScheduler.flush();
    expect(called, 2);

    // a.set(2, force: true); // force change
    // BeaconScheduler.flush();
    // expect(called, 3);

    dispose();
    a.value = 10;
    BeaconScheduler.flush();
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

  test('subscription to derived should run  until disposed when startNow=false',
      () async {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    final c = Beacon.derived(() => b() * 2, name: 'c');

    var called = 0;

    final dispose = c.subscribe((_) => called++, startNow: false);

    BeaconScheduler.flush();
    expect(called, 0);

    a.value = 2;
    BeaconScheduler.flush();
    expect(called, 1);

    a.value = 2; // no change
    BeaconScheduler.flush();
    expect(called, 1);

    a.set(2, force: true); // force change
    BeaconScheduler.flush();
    expect(called, 1); // propagation won't make it to c

    dispose();
    a.value = 10;
    BeaconScheduler.flush();
    expect(called, 1);
  });

  test('subscription to derived should run eagerly when it is empty', () {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    var cRan = 0;
    final c = Beacon.derived(
      () {
        cRan++;
        return b() * 2;
      },
      name: 'c',
    );

    var called = 0;

    expect(cRan, 0);

    c.subscribe((_) => called++, startNow: false);

    BeaconScheduler.flush();

    expect(called, 0);

    // derived is empty so we run it eagerly
    // so it can register itself as an observer of its sources
    expect(cRan, 1);
  });

  test('subscription to derived should NOT run eagerly when it is not empty',
      () async {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a() * 2, name: 'b');
    var cRan = 0;
    final c = Beacon.derived(
      () {
        cRan++;
        return b() * 2;
      },
      name: 'c',
    );

    var called = 0;

    Beacon.effect(() => c.value);

    BeaconScheduler.flush();
    expect(cRan, 1);

    c.subscribe((_) => called++, startNow: false);

    BeaconScheduler.flush();
    expect(called, 0);

    // derived isn't empty so its registered as an observer of its sources
    // so we don't need to run it eagerly
    expect(cRan, 1);
  });

  test(
    'subscription with startNow=false should not '
    'invoke callback immediately for derived',
    () async {
      final source = Beacon.writable(10);
      final derived = Beacon.derived(() => source.value * 2);

      // Initialize the derived by reading it
      expect(derived.value, 20);

      var callCount = 0;
      final receivedValues = <int>[];

      // Subscribe with startNow = false
      // The callback should NOT be invoked immediately
      final unsub = derived.subscribe(
        (value) {
          callCount++;
          receivedValues.add(value);
        },
        startNow: false,
      );

      BeaconScheduler.flush();

      // Bug #4: Previously, this would fail because the callback
      // was invoked immediately despite startNow=false
      expect(
        callCount,
        0,
        reason: 'startNow=false should prevent immediate callback',
      );

      expect(receivedValues, isEmpty);

      // Now trigger an update
      source.value = 15;
      BeaconScheduler.flush();

      // The callback should be invoked on actual updates
      expect(callCount, 1);
      expect(receivedValues, [30]);

      unsub();
    },
  );

  test(
    'subscription with startNow=false should not '
    'invoke callback immediately for lazy beacon',
    () async {
      final source = Beacon.lazyWritable<int>();

      var callCount = 0;
      final receivedValues = <int>[];

      // Subscribe with startNow = false
      // The callback should NOT be invoked immediately
      final unsub = source.subscribe(
        (value) {
          callCount++;
          receivedValues.add(value);
        },
        startNow: true,
      );

      BeaconScheduler.flush();

      // Bug #4: Previously, this would fail because the callback
      // was invoked immediately despite startNow=false
      expect(callCount, 0);

      expect(receivedValues, isEmpty);

      // Now trigger an update
      source.value = 15;
      BeaconScheduler.flush();

      // The callback should be invoked on actual updates
      expect(callCount, 1);
      expect(receivedValues, [15]);

      unsub();
    },
  );

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

  test('RangeError when subscription unsubscribes in callback(sync)', () {
    final beacon = Beacon.writable<int>(0);
    var mounted = true;

    late void Function() unsub;
    unsub = beacon.subscribe((v) {
      if (!mounted) unsub(); // Unsubscribe when "unmounted"
    }, synchronous: true);

    beacon.subscribe((v) {}, synchronous: true); // Second observer

    beacon.value = 1; // Works fine
    mounted = false;
    beacon.value = 2; // RangeError!
  });

  test('RangeError when subscription unsubscribes in callback', () {
    final beacon = Beacon.writable<int>(0);
    var mounted = true;

    late void Function() unsub;
    unsub = beacon.subscribe((v) {
      if (!mounted) unsub(); // Unsubscribe when "unmounted"
    });

    beacon.subscribe((v) {}, synchronous: true); // Second observer

    beacon.value = 1; // Works fine
    mounted = false;
    beacon.value = 2; // RangeError!
  });
}
