import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should call callback immediately when startNow is true', () {
    final beacon = Beacon.writable(42);
    var callCount = 0;
    var receivedValue = 0;

    beacon.subscribeSynchronously(
      (value) {
        callCount++;
        receivedValue = value;
      },
      startNow: true,
    );

    // Should be called immediately with current value
    expect(callCount, 1);
    expect(receivedValue, 42);
  });

  test('should not call callback immediately when startNow is false', () {
    final beacon = Beacon.writable(42);
    var callCount = 0;

    beacon.subscribeSynchronously(
      (value) => callCount++,
      startNow: false,
    );

    // Should not be called immediately
    expect(callCount, 0);
  });

  test('should call callback synchronously when beacon value changes', () {
    final beacon = Beacon.writable(10);
    var callCount = 0;
    final receivedValues = <int>[];

    beacon.subscribeSynchronously(
      (value) {
        callCount++;
        receivedValues.add(value);
      },
      startNow: true,
    );

    expect(callCount, 1);
    expect(receivedValues, [10]);

    // Change value - should be called immediately
    beacon.value = 20;
    expect(callCount, 2);
    expect(receivedValues, [10, 20]);

    // Change again
    beacon.value = 30;
    expect(callCount, 3);
    expect(receivedValues, [10, 20, 30]);
  });

  test('should not call callback when value does not change', () {
    final beacon = Beacon.writable(10);
    var callCount = 0;

    beacon.subscribeSynchronously(
      (value) {
        callCount++;
      },
      startNow: true,
    );

    expect(callCount, 1);

    // Set same value - should not call callback
    beacon.value = 10;
    expect(callCount, 1);
  });

  test('should call callback when value changes even if startNow is false', () {
    final beacon = Beacon.writable(10);
    var callCount = 0;
    final receivedValues = <int>[];

    beacon.subscribeSynchronously(
      (value) {
        callCount++;
        receivedValues.add(value);
      },
      startNow: false,
    );

    expect(callCount, 0);
    expect(receivedValues, isEmpty);

    // Change value - should be called
    beacon.value = 20;
    expect(callCount, 1);
    expect(receivedValues, [20]);
  });

  test('should dispose properly and stop receiving updates', () async {
    final beacon = Beacon.writable(10);
    var callCount = 0;

    final unsub = beacon.subscribeSynchronously(
      (value) => callCount++,
      startNow: true,
    );

    expect(callCount, 1);

    // Dispose the subscription
    unsub();

    await delay();

    // Change value after disposal - should not call callback
    beacon.value = 20;
    expect(callCount, 1);
  });

  test('should handle force update correctly', () {
    final beacon = Beacon.writable(10);
    var callCount = 0;

    beacon.subscribeSynchronously(
      (value) => callCount++,
      startNow: true,
    );

    expect(callCount, 1);

    // Set same value without force - should not call
    beacon.value = 10;
    expect(callCount, 1);

    // Set same value with force - should call
    beacon.set(10, force: true);
    expect(callCount, 2);
  });

  test('should work with null values', () {
    final beacon = Beacon.writable<String?>(null);
    var callCount = 0;
    final receivedValues = <String?>[];

    beacon.subscribeSynchronously(
      (value) {
        callCount++;
        receivedValues.add(value);
      },
      startNow: true,
    );

    expect(callCount, 1);
    expect(receivedValues, [null]);

    // Change to non-null value
    beacon.value = 'hello';
    expect(callCount, 2);
    expect(receivedValues, [null, 'hello']);

    // Change back to null
    beacon.value = null;
    expect(callCount, 3);
    expect(receivedValues, [null, 'hello', null]);
  });

  test('should handle multiple subscriptions', () {
    final beacon = Beacon.writable(10);
    var callCount1 = 0;
    var callCount2 = 0;

    beacon.subscribeSynchronously(
      (value) {
        callCount1++;
      },
      startNow: true,
    );

    beacon.subscribeSynchronously(
      (value) {
        callCount2++;
      },
      startNow: true,
    );

    expect(callCount1, 1);
    expect(callCount2, 1);

    // Change value - both should be called
    beacon.value = 20;
    expect(callCount1, 2);
    expect(callCount2, 2);
  });

  test('should handle disposal of one subscription while others remain',
      () async {
    final beacon = Beacon.writable(10);
    var callCount1 = 0;
    var callCount2 = 0;

    final subscription1 = beacon.subscribeSynchronously(
      (value) {
        callCount1++;
      },
      startNow: true,
    );

    final subscription2 = beacon.subscribeSynchronously(
      (value) {
        callCount2++;
      },
      startNow: true,
    );

    expect(callCount1, 1);
    expect(callCount2, 1);

    // Dispose first subscription
    subscription1();

    await delay(k10ms);

    // Change value - only second subscription should be called
    beacon.value = 20;
    expect(callCount1, 1);
    expect(callCount2, 2);

    subscription2();
  });

  test('should work with complex derived chains', () {
    final a = Beacon.writable(2);
    final b = Beacon.derived(() => a.value * 3);
    final c = Beacon.derived(() => b.value + 1);
    var callCount = 0;
    final receivedValues = <int>[];
    var syncCallCount = 0;

    c.subscribe(
      (value) {
        callCount++;
        receivedValues.add(value);
      },
      startNow: true,
    );

    a.subscribeSynchronously((_) => syncCallCount++);

    expect(syncCallCount, 1);

    BeaconScheduler.flush();
    expect(callCount, 1);
    expect(syncCallCount, 1);
    expect(receivedValues, [7]); // (2 * 3) + 1 = 7

    // Change source - should propagate through chain
    a.value = 5;
    expect(syncCallCount, 2);
    BeaconScheduler.flush();
    expect(callCount, 2);
    expect(receivedValues, [7, 16]); // (5 * 3) + 1 = 16
  });

  test('should handle laxy beacons', () {
    final source = Beacon.lazyWritable<int>();
    var callCount = 0;

    // Try to subscribe to empty beacon
    source.subscribeSynchronously(
      (value) {
        callCount++;
      },
      startNow: true,
    );

    // Should not call callback for empty beacon
    expect(callCount, 0);

    // Set value - should call callback
    source.value = 42;
    expect(callCount, 1);
  });

  test('should handle disposal of source beacon', () {
    final beacon = Beacon.writable(10);
    var callCount = 0;

    beacon.subscribeSynchronously(
      (value) => callCount++,
      startNow: true,
    );

    expect(callCount, 1);

    // Dispose the source beacon
    beacon.dispose();

    // Subscription should be disposed automatically
    // (This is handled by the _sourceDisposed method)
    expect(beacon.isDisposed, true);
  });

  test('should handle multiple synchronous subscriptions on same beacon', () {
    final beacon = Beacon.writable(10);
    var callCount1 = 0;
    var callCount2 = 0;
    final receivedValues1 = <int>[];
    final receivedValues2 = <int>[];

    final subscription1 = beacon.subscribeSynchronously(
      (value) {
        callCount1++;
        receivedValues1.add(value);
      },
      startNow: true,
    );

    final subscription2 = beacon.subscribeSynchronously(
      (value) {
        callCount2++;
        receivedValues2.add(value);
      },
      startNow: true,
    );

    expect(callCount1, 1);
    expect(callCount2, 1);
    expect(receivedValues1, [10]);
    expect(receivedValues2, [10]);

    // Change value - both should be called synchronously
    beacon.value = 20;
    expect(callCount1, 2);
    expect(callCount2, 2);
    expect(receivedValues1, [10, 20]);
    expect(receivedValues2, [10, 20]);

    subscription1();
    subscription2();
  });

  test('should work when async subs are made on the same beacon', () {
    final source = Beacon.writable(0);

    var syncCalled = 0;
    var sync2Called = 0;
    var asyncCalled = 0;
    var async2Called = 0;

    source.subscribe((_) => asyncCalled++);
    source.subscribe((_) => async2Called++);
    source.subscribeSynchronously((_) => syncCalled++);
    source.subscribeSynchronously((_) => sync2Called++);

    expect(syncCalled, 1);
    expect(sync2Called, 1);
    expect(asyncCalled, 0);
    expect(async2Called, 0);

    BeaconScheduler.flush();

    expect(syncCalled, 1);
    expect(sync2Called, 1);
    expect(asyncCalled, 1);
    expect(async2Called, 1);

    source.set(1);
    source.set(2);
    source.set(3);

    expect(syncCalled, 4);
    expect(sync2Called, 4);
    expect(asyncCalled, 1);
    expect(async2Called, 1);

    BeaconScheduler.flush();

    expect(syncCalled, 4);
    expect(sync2Called, 4);
    expect(asyncCalled, 2);
    expect(async2Called, 2);
  });

  test('should work when async subs are made on the same beacon (buffered)',
      () {
    final source = Beacon.bufferedCount<int>(2);

    var syncCalled = 0;
    var sync2Called = 0;
    var asyncCalled = 0;
    var async2Called = 0;

    source.subscribe((_) => asyncCalled++);
    source.subscribe((_) => async2Called++);
    source.subscribeSynchronously((_) => syncCalled++);
    source.subscribeSynchronously((_) => sync2Called++);

    expect(syncCalled, 1);
    expect(sync2Called, 1);
    expect(asyncCalled, 0);
    expect(async2Called, 0);

    BeaconScheduler.flush();

    expect(syncCalled, 1);
    expect(sync2Called, 1);
    expect(asyncCalled, 1);
    expect(async2Called, 1);

    source.add(1);
    source.add(2);

    expect(syncCalled, 2);
    expect(sync2Called, 2);
    expect(asyncCalled, 1);
    expect(async2Called, 1);

    BeaconScheduler.flush();

    expect(syncCalled, 2);
    expect(sync2Called, 2);
    expect(asyncCalled, 2);
    expect(async2Called, 2);
  });

  test('should not throw when unsub in own callback', () {
    final beacon = Beacon.writable<int>(0);
    var mounted = true;

    late void Function() unsub;
    unsub = beacon.subscribeSynchronously(
      (v) {
        if (!mounted) unsub(); // Unsubscribe when "unmounted"
      },
    );

    beacon.subscribeSynchronously((v) {}); // extra observers
    beacon.subscribe((v) {}); // extra observers

    beacon.value = 1;
    mounted = false;
    beacon.value = 2;
  });

  test('should throw when beacon is disposed in subscription callback', () {
    final beacon = Beacon.writable<int>(0);
    var mounted = true;

    beacon.subscribeSynchronously(
      (v) {
        if (!mounted) beacon.dispose(); // Unsubscribe when "unmounted"
      },
    );

    beacon.subscribeSynchronously((v) {}); // extra observers
    beacon.subscribe((v) {}); // extra observers

    beacon.value = 1;
    mounted = false;

    expect(() => beacon.set(2), throwsException);
  });

  test(
    'sync subscriptions can dispose other sync subscriptions during iteration',
    () async {
      final beacon = Beacon.writable(0);
      var firstCalls = 0;
      var secondCalls = 0;

      late void Function() unsubscribeFirst;

      unsubscribeFirst = beacon.subscribeSynchronously(
        (_) {
          firstCalls++;
        },
        startNow: true,
      );

      beacon.subscribeSynchronously(
        (_) {
          secondCalls++;
          if (secondCalls == 1) {
            // Dispose the first subscription while the observer list
            // is being iterated. This must not cause concurrent
            // modification errors and must be handled via microtask.
            unsubscribeFirst();
          }
        },
        startNow: true,
      );

      // Initial subscriptions run once each
      expect(firstCalls, 1);
      expect(secondCalls, 1);

      // First update: both subscriptions are still present
      beacon.value = 1;
      expect(firstCalls, 2);
      expect(secondCalls, 2);

      // Allow the scheduled microtask from unsubscribeFirst to run
      await delay();

      // Second update: only the second subscription should be called
      beacon.value = 2;
      expect(firstCalls, 2, reason: 'subscription1 should be disposed');
      expect(secondCalls, 3, reason: 'subscription2 should remain active');
    },
  );

  test(
    'sync and async subscriptions can dispose themselves without races',
    () async {
      final beacon = Beacon.writable(0);

      var syncCalls = 0;
      var asyncCalls = 0;

      late void Function() unsubscribeSync;
      late void Function() unsubscribeAsync;

      unsubscribeSync = beacon.subscribeSynchronously(
        (_) {
          syncCalls++;
          if (syncCalls == 2) {
            // Dispose sync subscription on the second call
            unsubscribeSync();
          }
        },
        startNow: true,
      );

      unsubscribeAsync = beacon.subscribe(
        (_) {
          asyncCalls++;
          if (asyncCalls == 1) {
            // Dispose async subscription on the first async flush
            unsubscribeAsync();
          }
        },
        startNow: true,
      );

      // Initial sync subscription runs immediately
      expect(syncCalls, 1);
      // Async subscription is queued until flush
      expect(asyncCalls, 0);

      BeaconScheduler.flush();

      // After flush, async subscription should have run once
      expect(asyncCalls, 1);

      // First explicit update: sync runs and schedules its own disposal
      beacon.value = 1;
      expect(syncCalls, 2);

      BeaconScheduler.flush();

      // Async subscription was already disposed after first call
      expect(asyncCalls, 1);

      // Allow any scheduled microtasks from sync disposal to complete
      await delay();

      // Second explicit update: neither subscription should be called again
      beacon.value = 2;
      expect(syncCalls, 2, reason: 'sync subscription should be disposed');
      BeaconScheduler.flush();
      expect(asyncCalls, 1, reason: 'async subscription should be disposed');
    },
  );
}
