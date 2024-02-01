// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:state_beacon/state_beacon.dart';

class MockTodoController extends Mock implements TodoController {}

void main() {
  final todoCtrl = MockTodoController();

  testWidgets('Todo Page Test', (WidgetTester tester) async {
    final todosBeacon = Beacon.list(<Todo>[]);
    final inputTextBeacon = Beacon.writable('');
    final filterBeacon = Beacon.writable(Filter.active);

    final filteredTodos = Beacon.derived(() {
      final todos = todosBeacon.value;

      return switch (filterBeacon.value) {
        Filter.all => todos.toList(),
        Filter.active => todos.where((e) => !e.completed).toList(),
        Filter.done => todos.where((e) => e.completed).toList()
      };
    });

    when(() => todoCtrl.todosBeacon).thenReturn(todosBeacon);
    when(() => todoCtrl.inputTextBeacon).thenReturn(inputTextBeacon);
    when(() => todoCtrl.filterBeacon).thenReturn(filterBeacon);
    when(() => todoCtrl.filteredTodos).thenReturn(filteredTodos);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Provider<TodoController>(
            create: (_) => todoCtrl,
            child: const TodoPage(),
          ),
        ),
      ),
    );

    todosBeacon.add(
      const Todo(
        id: '1',
        description: 'new todo',
      ),
    );

    await tester.pump();

    expect(find.text('new todo'), findsOneWidget);

    filterBeacon.value = Filter.done;

    await tester.pump();

    expect(find.text('new todo'), findsNothing);

    todosBeacon.add(
      const Todo(
        id: '2',
        description: 'done todo',
        completed: true,
      ),
    );

    // find checkbox
    await tester.pump();

    expect(find.byType(Checkbox), findsOneWidget);

    expect(find.text('done todo'), findsOneWidget);
    expect(find.text('new todo'), findsNothing);

    filterBeacon.value = Filter.active;

    await tester.pump();

    expect(find.text('new todo'), findsOneWidget);
    expect(find.text('done todo'), findsNothing);

    filterBeacon.value = Filter.all;

    await tester.pump();

    expect(find.byType(Checkbox), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('1 delete button')));

    await tester.pump();

    expect(find.text('new todo'), findsNothing);
    expect(find.text('done todo'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('2 delete button')));

    await tester.pump();

    expect(find.text('done todo'), findsNothing);
  });
}
