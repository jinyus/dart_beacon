part of 'todo.dart';

typedef ID = String;

enum Filter { all, active, done }

@immutable
class Todo {
  const Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  final ID id;
  final String description;
  final bool completed;

  Todo copyWith({
    ID? id,
    String? description,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}
