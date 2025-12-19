part of 'todo.dart';

class TodoController extends BeaconController {
  late final todosBeacon = B.hashMap(<ID, Todo>{});
  late final inputTextBeacon = B.textEditing(text: '');
  late final filterBeacon = B.writable(Filter.all);

  late final filteredTodos = B.derived(() {
    final todos = todosBeacon.value;

    return switch (filterBeacon.value) {
      Filter.all => todos.values.toList(),
      Filter.active => todos.values.where((e) => !e.completed).toList(),
      Filter.done => todos.values.where((e) => e.completed).toList()
    };
  });

  void addTodo() {
    final text = inputTextBeacon.text.trim();
    if (text.isNotEmpty) {
      final id = DateTime.now().toIso8601String();
      todosBeacon[id] = Todo(id: id, description: text);
    }
  }

  void deleteTodo(String todoID) => todosBeacon.remove(todoID);

  void toggleTodo(bool completed, String todoID) {
    final todo = todosBeacon[todoID]!;
    todosBeacon[todoID] = todo.copyWith(completed: completed);
  }
}
