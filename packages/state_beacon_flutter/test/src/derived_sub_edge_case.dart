import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon_flutter/state_beacon_flutter.dart';

void main() {
  group('DerivedBeacon subscription bug', () {
    testWidgets('BUG: Dependency change before .watch() breaks subscription',
        (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      BeaconScheduler.useFlutterScheduler();

      // Setup: Two WritableBeacons -> one DerivedBeacon
      final a = Beacon.writable<String>('a');
      final b = Beacon.writable<int>(0);
      final derived = Beacon.derived<String>(
        () {
          return '${a.value}-${b.value}';
        },
        name: 'derived',
      );

      // Step 1: Access .value (first evaluation)
      expect(derived.value, 'a-0');

      // Step 2: Change first dependency (triggers re-evaluation)
      a.value = 'A';
      await tester.pump();

      // Step 3: Now subscribe with .watch()
      var buildCount = 0;
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = derived.watch(context);
              buildCount++;
              lastValue = value;
              return ElevatedButton(
                onPressed: () {
                  b.value = 42;
                },
                child: Text(value),
              );
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(lastValue, 'A-0');

      // Step 4: Change the SECOND dependency
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // BUG: Widget should rebuild but it doesn't!
      expect(
        buildCount,
        greaterThan(1),
        reason: 'Widget should rebuild when b changes',
      );
      expect(lastValue, 'A-42', reason: 'derived should show updated value');
    });

    testWidgets('WORKS: Same pattern WITHOUT dependency change before .watch()',
        (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      BeaconScheduler.useFlutterScheduler();

      final a = Beacon.writable<String>('a');
      final b = Beacon.writable<int>(0);
      final derived = Beacon.derived<String>(
        () {
          return '${a.value}-${b.value}';
        },
        name: 'derived',
      );

      // Step 1: Access .value (first evaluation)
      expect(derived.value, 'a-0');

      // Step 2: SKIP - no dependency change

      // Step 3: Subscribe with .watch()
      var buildCount = 0;
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = derived.watch(context);
              buildCount++;
              lastValue = value;
              return ElevatedButton(
                onPressed: () {
                  b.value = 42;
                },
                child: Text(value),
              );
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(lastValue, 'a-0');

      // Step 4: Change b
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // WORKS: Widget rebuilds correctly
      expect(buildCount, greaterThan(1), reason: 'Widget should rebuild');
      expect(lastValue, 'a-42');
    });

    testWidgets('WORKS: Dependency change AFTER .watch() works fine',
        (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      BeaconScheduler.useFlutterScheduler();

      final a = Beacon.writable<String>('a');
      final b = Beacon.writable<int>(0);
      final derived = Beacon.derived<String>(
        () {
          return '${a.value}-${b.value}';
        },
        name: 'derived',
      );

      // Step 1: Access .value (first evaluation)
      expect(derived.value, 'a-0');

      // Step 2: Build widget with .watch() BEFORE any dependency change
      var buildCount = 0;
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = derived.watch(context);
              buildCount++;
              lastValue = value;
              return ElevatedButton(
                onPressed: () {
                  b.value = 42;
                },
                child: Text(value),
              );
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Step 3: Change a AFTER .watch() was called
      a.value = 'A';
      await tester.pump();

      expect(
        buildCount,
        greaterThan(1),
        reason: 'Widget should rebuild when a changes',
      );
      expect(lastValue, 'A-0');

      final buildCountAfterA = buildCount;

      // Step 4: Change b
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // WORKS: Widget rebuilds correctly
      expect(
        buildCount,
        greaterThan(buildCountAfterA),
        reason: 'Widget should rebuild',
      );
      expect(lastValue, 'A-42');
    });
  });
}
