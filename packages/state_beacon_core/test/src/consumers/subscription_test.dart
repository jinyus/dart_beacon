import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

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

  test(
      'should notify subscription after peeking with '
      'startNow=false and type is nullable for writable', () {
    final a = Beacon.lazyWritable<int?>();

    var subCalled = 0;

    a.subscribe((_) => subCalled++, startNow: false);

    BeaconScheduler.flush();

    expect(subCalled, 0);

    a.value = 1;

    BeaconScheduler.flush();

    expect(subCalled, 1);
  });
}
