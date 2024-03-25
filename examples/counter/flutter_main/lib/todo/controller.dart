part of 'todo.dart';

class TodoController extends BeaconController {
  late final todosBeacon = B.list(<Todo>[]);
  late final inputTextBeacon = B.writable('');
  late final filterBeacon = B.writable(Filter.all);

  late final filteredTodos = B.derived(() {
    final todos = todosBeacon.value;

    return switch (filterBeacon.value) {
      Filter.all => todos.toList(),
      Filter.active => todos.where((e) => !e.completed).toList(),
      Filter.done => todos.where((e) => e.completed).toList()
    };
  });

  void addTodo() {
    final text = inputTextBeacon.value;
    if (text.isNotEmpty) {
      todosBeacon.add(
        Todo(
          id: DateTime.now().toIso8601String(),
          description: text,
        ),
      );
      inputTextBeacon.value = '';
    }
  }
}
