import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:state_beacon/state_beacon.dart';

import 'package:vgv_best_practices/counter/counter.dart';

import '../../helpers/helpers.dart';

class MockCounterController extends Mock implements CounterController {}

void main() {
  group('CounterPage', () {
    testWidgets('renders CounterView', (tester) async {
      await tester.pumpApp(const CounterPage());
      expect(find.byType(CounterView), findsOneWidget);
    });
  });

  group('CounterView', () {
    late MockCounterController counterController;

    setUp(() {
      counterController = MockCounterController();
    });

    testWidgets('renders current count', (tester) async {
      const state = 42;
      when(() => counterController.count).thenReturn(Beacon.readable(state));

      await tester.pumpApp(
        Provider<CounterController>(
          create: (_) => counterController,
          child: Builder(
            builder: (context) {
              return const CounterView();
            },
          ),
        ),
      );

      expect(find.text('$state'), findsOneWidget);
    });

    testWidgets('calls increment when increment button is tapped',
        (tester) async {
      when(() => counterController.count).thenReturn(Beacon.readable(0));
      when(() => counterController.increment()).thenReturn(null);
      await tester.pumpApp(
        Provider<CounterController>(
          create: (_) => counterController,
          child: const CounterView(),
        ),
      );
      await tester.tap(find.byIcon(Icons.add));
      verify(() => counterController.increment()).called(1);
    });

    testWidgets('calls decrement when decrement button is tapped',
        (tester) async {
      when(() => counterController.count).thenReturn(Beacon.readable(0));
      when(() => counterController.decrement()).thenReturn(null);
      await tester.pumpApp(
        Provider<CounterController>(
          create: (_) => counterController,
          child: const CounterView(),
        ),
      );
      await tester.tap(find.byIcon(Icons.remove));
      verify(() => counterController.decrement()).called(1);
    });
  });
}
