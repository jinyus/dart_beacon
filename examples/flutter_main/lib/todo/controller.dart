part of 'todo.dart';

class Controller {
  final todosBeacon = Beacon.list(<Todo>[]);
  final inputTextBeacon = Beacon.writable('');
  final filterBeacon = Beacon.writable(Filter.all);

  late final filteredTodos = Beacon.derived(() {
    final todos = todosBeacon.value;

    return switch (filterBeacon.value) {
      Filter.all => todos,
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
