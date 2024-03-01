import 'package:counter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:mocktail/mocktail.dart';
import 'package:state_beacon/state_beacon.dart';

class MockCounterController extends Mock implements Controller {}

// Helper extension to reduce boilerplate
extension PumpApp on WidgetTester {
  Future<void> pumpApp(MockCounterController controller) {
    return pumpWidget(
      LiteRefScope(
        overrides: [
          countControllerRef.overrideWith((_) => controller),
        ],
        child: const MyApp(),
      ),
    );
  }
}

void main() {
  final controller = MockCounterController();

  testWidgets('renders current count', (tester) async {
    final beacon = Beacon.writable(42);
    when(() => controller.count).thenReturn(beacon);

    await tester.pumpApp(controller);

    expect(find.text('${beacon.value}'), findsOneWidget);
  });

  testWidgets('calls increment when add button is tapped', (tester) async {
    final beacon = Beacon.writable(0);

    when(() => controller.count).thenReturn(beacon);
    when(controller.increment).thenReturn(beacon.increment());

    await tester.pumpApp(controller);

    await tester.tap(find.byIcon(Icons.add));
    verify(controller.increment).called(1);

    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('calls decrement when minus button is tapped', (tester) async {
    final beacon = Beacon.writable(0);

    when(() => controller.count).thenReturn(beacon);
    when(controller.decrement).thenReturn(beacon.decrement());

    await tester.pumpApp(controller);

    await tester.tap(find.byIcon(Icons.remove));
    verify(controller.decrement).called(1);

    await tester.pumpAndSettle();
    expect(find.text('-1'), findsOneWidget);
  });

  testWidgets('rebuilds when beacon value changes', (tester) async {
    final beacon = Beacon.writable(42);

    when(() => controller.count).thenReturn(beacon);

    await tester.pumpApp(controller);

    expect(find.text('42'), findsOneWidget);

    beacon.value = 43;
    await tester.pumpAndSettle();
    expect(find.text('43'), findsOneWidget);

    beacon.value = -100;
    await tester.pumpAndSettle();
    expect(find.text('-100'), findsOneWidget);
  });
}
