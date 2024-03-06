import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

extension TesterX on WidgetTester {
  Future<void> pumpApp(Widget child) async {
    await pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LiteRefScope(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('should watch beacon inside ref', (tester) async {
    final beaconRef = Ref.scoped((ctx) => Beacon.writable(0));

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final count = beaconRef.watch(context);
          return Column(
            children: [
              Text('$count'),
              TextButton(
                onPressed: () => beaconRef.of(context).increment(),
                child: const SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byType(TextButton));

    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('should select beacon inside controller ref', (tester) async {
    final controllerRef = Ref.scoped((ctx) => TestController());

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final count = controllerRef.select(context, (c) => c.count);
          return Column(
            children: [
              Text('$count'),
              TextButton(
                onPressed: () {
                  controllerRef.of(context).count.increment();
                },
                child: const SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byType(TextButton));

    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('should select 2 beacons inside controller ref', (tester) async {
    final controllerRef = Ref.scoped((ctx) => TestController());

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final (count, doubleCount) = controllerRef.select2(
            context,
            (c) => (c.count, c.doubledCount),
          );
          return Column(
            children: [
              Text('$count $doubleCount'),
              TextButton(
                onPressed: () {
                  controllerRef.of(context).count.increment();
                },
                child: const SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );

    expect(find.text('0 0'), findsOneWidget);

    await tester.tap(find.byType(TextButton));

    await tester.pump();

    expect(find.text('1 2'), findsOneWidget);
  });

  testWidgets('should select 3 beacons inside controller ref', (tester) async {
    final controllerRef = Ref.scoped((ctx) => TestController());

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final (count, doubleCount, tripleCount) = controllerRef.select3(
            context,
            (c) => (c.count, c.doubledCount, c.tripledCount),
          );
          return Column(
            children: [
              Text('$count $doubleCount $tripleCount'),
              TextButton(
                onPressed: () {
                  controllerRef.of(context).count.increment();
                },
                child: const SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );

    expect(find.text('0 0 0'), findsOneWidget);

    await tester.tap(find.byType(TextButton));

    await tester.pump();

    expect(find.text('1 2 3'), findsOneWidget);
  });
}

class TestController extends BeaconController {
  late final count = B.writable(0);
  late final doubledCount = B.derived(() => count.value * 2);
  late final tripledCount = B.derived(() => count.value * 3);
}
