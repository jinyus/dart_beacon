// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:state_beacon/state_beacon.dart';

void main() {
  testWidgets('Todo Page Test', (WidgetTester tester) async {
    final controller = TodoController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiteRefScope(
            overrides: {
              todoControllerRef.overrideWith((_) => controller),
            },
            child: const TodoPage(),
          ),
        ),
      ),
    );

    // adding todo
    final inputFinder = find.byKey(const Key('todoInput'));
    expect(inputFinder, findsOneWidget);

    await tester.enterText(inputFinder, 'todo #1');
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('todo #1'), findsOneWidget);

    // filter by done
    await tester.tap(find.byKey(const ValueKey('Filter.done button')));
    await tester.pumpAndSettle();

    expect(find.text('todo #1'), findsNothing);

    // adding another todo
    await tester.enterText(inputFinder, 'todo #2');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('Filter.all button')));
    await tester.pumpAndSettle();

    expect(controller.todosBeacon.value.length, 2);

    expect(find.text('todo #1'), findsOneWidget);
    expect(find.text('todo #2'), findsOneWidget);

    final todo2ID = controller.todosBeacon.value.values.last.id;
    final todo1ID = controller.todosBeacon.value.values.first.id;

    await tester.tap(find.byKey(ValueKey('$todo2ID checkbox')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('Filter.done button')));
    await tester.pumpAndSettle();

    expect(find.text('todo #1'), findsNothing);
    expect(find.text('todo #2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('Filter.active button')));
    await tester.pumpAndSettle();

    expect(find.text('todo #1'), findsOneWidget);
    expect(find.text('todo #2'), findsNothing);

    await tester.tap(find.byKey(ValueKey('$todo1ID delete button')));
    await tester.pumpAndSettle();

    expect(find.text('todo #1'), findsNothing);
    expect(find.text('todo #2'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('Filter.all button')));
    await tester.pumpAndSettle();

    expect(controller.todosBeacon.value.length, 1);
    expect(find.text('todo #1'), findsNothing);
    expect(find.text('todo #2'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('$todo2ID delete button')));
    await tester.pumpAndSettle();

    expect(find.text('todo #2'), findsNothing);

    expect(controller.todosBeacon.value.length, 0);
  });
}
