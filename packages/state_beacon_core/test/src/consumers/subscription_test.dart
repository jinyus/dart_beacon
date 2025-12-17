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

    dispose();
    a.value = 10;
    BeaconScheduler.flush();
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

  test('should notify all observers', () {
    final count = Beacon.writable(0);
    final triple = Beacon.derived(() => count.value * 3);

    var sub1Called = 0;
    var sub2Called = 0;

    triple.subscribe((_) => ++sub1Called);
    triple.subscribe((_) => ++sub2Called);

    BeaconScheduler.flush();

    expect(sub1Called, 1);
    expect(sub2Called, 1);

    count.increment();

    BeaconScheduler.flush();

    expect(sub1Called, 2);
    expect(sub2Called, 2, reason: 'async sub should also be called');
  });

  test('should not throw when unsub in own callback', () {
    final beacon = Beacon.writable<int>(0);
    var mounted = true;

    late void Function() unsub;
    unsub = beacon.subscribe(
      (v) {
        if (!mounted) unsub(); // Unsubscribe when "unmounted"
      },
    );

    beacon.subscribeSynchronously((v) {});
    beacon.subscribe((v) {});
    beacon.value = 1;
    mounted = false;
    beacon.value = 2;
    BeaconScheduler.flush();
  });

  test('should notify all observers (sync+async)', () {
    final count = Beacon.writable(0);
    final triple = Beacon.derived(() => count.value * 3);

    var syncCalled = 0;
    var asyncCalled = 0;
    var async2Called = 0;

    triple.subscribe((_) => ++asyncCalled);
    triple.subscribe((_) => ++async2Called);
    count.subscribeSynchronously((_) => syncCalled++);

    BeaconScheduler.flush();

    expect(asyncCalled, 1);
    expect(async2Called, 1);
    expect(syncCalled, 1);

    count.increment();
    expect(syncCalled, 2);

    BeaconScheduler.flush();

    expect(syncCalled, 2);
    expect(asyncCalled, 2);
  });

  test('derived subscription does not emit when value is unchanged', () {
    final a = Beacon.writable(0, name: 'a');
    final b = Beacon.derived(() => a().isEven ? 'even' : 'odd');

    var callCount = 0;
    final received = <String>[];

    final unsub = b.subscribe((value) {
      callCount++;
      received.add(value);
    });

    BeaconScheduler.flush();

    expect(callCount, 1);
    expect(received, ['even']);

    // Change source without changing derived result
    a.value = 2;
    BeaconScheduler.flush();

    expect(callCount, 1, reason: 'derived output did not change');

    // Force another "even" value
    a.set(4, force: true);
    BeaconScheduler.flush();

    expect(
      callCount,
      1,
      reason: 'forcing same derived value should not notify',
    );

    unsub();
  });

  test(
    'derived subscription with startNow=false only emits on updates',
    () {
      final source = Beacon.writable(1);
      final doubled = Beacon.derived(() => source() * 2);

      var derivedEvaluations = 0;
      final deep = Beacon.derived(
        () {
          derivedEvaluations++;
          return doubled() + 1;
        },
      );

      var callCount = 0;
      final observed = <int>[];

      final unsub = deep.subscribe(
        (value) {
          callCount++;
          observed.add(value);
        },
        startNow: false,
      );

      // Before flushing, nothing should have run yet
      expect(derivedEvaluations, 0);
      expect(callCount, 0);

      BeaconScheduler.flush();

      // The derived chain should have initialized once, but
      // the subscription callback should still not have run
      expect(derivedEvaluations, 1);
      expect(callCount, 0);

      // Now change the source and flush again
      source.value = 2;
      BeaconScheduler.flush();

      expect(derivedEvaluations, 2);
      expect(callCount, 1);
      expect(observed, [5]); // (2 * 2) + 1

      unsub();
    },
  );
}
