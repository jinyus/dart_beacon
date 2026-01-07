import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
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

  test('should notify subscription if derived has observers', () async {
    final a = Beacon.writable(1);
    final d = Beacon.derived(() => a() * 2);

    var sub1Called = 0;
    var sub2Called = 0;

    d.subscribe((_) => sub1Called++);

    await delay();

    expect(sub1Called, 1);
    expect(d.listenersCount, 1);

    d.subscribe((_) => sub2Called++, startNow: false);

    await delay();

    expect(sub1Called, 1);
    expect(sub2Called, 0);
    expect(d.listenersCount, 2);

    a.increment();

    BeaconScheduler.flush();

    expect(sub1Called, 2);
    expect(sub2Called, 1);
    expect(d.listenersCount, 2);
  });

  test('should notify subscription after peeking with startNow=false', () {
    final a = Beacon.writable(1);
    final d = Beacon.derived(() => a() * 2);

    var subCalled = 0;

    d.subscribe((_) => subCalled++, startNow: false);

    expect(d.isEmpty, true);

    d.peek();
    BeaconScheduler.flush();

    expect(subCalled, 0);

    a.increment();

    BeaconScheduler.flush();

    expect(subCalled, 1);
  });

  test(
      'should notify subscription after peeking with '
      'startNow=false and type is nullable', () {
    final a = Beacon.writable(1);
    final d = Beacon.derived<int?>(() => a() * 2);

    var subCalled = 0;

    d.subscribe((_) => subCalled++, startNow: false);

    expect(d.isEmpty, true);

    d.peek();
    BeaconScheduler.flush();

    expect(subCalled, 0);

    a.increment();

    BeaconScheduler.flush();

    expect(subCalled, 1);
  });

  test('should work when accessed after sub when startNow=false', () {
    final a = Beacon.writable<String>('a');
    final b = Beacon.writable<int>(0);
    final derived = Beacon.derived<String>(
      () {
        return '${a.value}-${b.value}';
      },
      name: 'derived',
    );

    // BeaconObserver.useLogging();

    expect(derived.value, 'a-0');
    a.value = 'A';

    var called = 0;
    derived.subscribe((v) => called++, startNow: false);

    BeaconScheduler.flush();
    expect(derived.peek(), 'A-0');
    expect(called, 0);

    b.increment();
    BeaconScheduler.flush();

    expect(called, 1);
  });
}
