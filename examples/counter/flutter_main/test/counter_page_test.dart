// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/counter/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:state_beacon/state_beacon.dart';

class MockCounterController extends Mock implements CounterController {}

void main() {
  final counterCtrl = MockCounterController();

  testWidgets('Counter Page Test', (WidgetTester tester) async {
    final count = Beacon.writable(0);
    final derived = Beacon.writable<AsyncValue<String>>(AsyncIdle<String>());

    when(() => counterCtrl.count).thenReturn(count);
    when(() => counterCtrl.futureCount).thenReturn(derived);
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiteRefScope(
            overrides: [
              counterControllerRef.overrideWith((_) => counterCtrl),
            ],
            child: const CounterPage(),
          ),
        ),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    derived.value = AsyncData('1 second has passed.');

    await tester.pump();

    expect(find.text('1 second has passed.'), findsOneWidget);

    derived.value = AsyncError('error');

    await tester.pump();

    expect(find.text('error'), findsOneWidget);

    count.value = 4;

    await tester.pumpAndSettle();

    expect(find.text('Count cannot be greater than 3'), findsOneWidget);

    count.value = -1;

    await tester.pumpAndSettle();

    expect(find.text('Count cannot be negative'), findsOneWidget);
  });
}
