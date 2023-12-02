import 'dart:math' as math;

import 'package:example/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_beacon/flutter_state_beacon.dart';

enum Filter { all, active, completed }

final todosBeacon = Beacon.writable(<Todo>[]);
final inputTextBeacon = Beacon.writable('');
final filterBeacon = Beacon.writable(Filter.all);

final filteredTodos = Beacon.derived(() {
  final filter = filterBeacon.value;

  final todos = todosBeacon.value;

  return switch (filter) {
    Filter.all => todos,
    Filter.active => todos.where((e) => !e.completed).toList(),
    Filter.completed => todos.where((e) => e.completed).toList()
  };
});

void addTodo() {
  final text = inputTextBeacon.value;
  if (text.isNotEmpty) {
    todosBeacon.value = [
      ...todosBeacon.peek(),
      Todo(
        id: DateTime.now().toIso8601String(),
        description: text,
      ),
    ];
    inputTextBeacon.value = '';
  }
}

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: math.min(500, MediaQuery.of(context).size.width * 0.8),
          child: const Column(
            children: [
              Text('Todo', style: TextStyle(fontSize: 48)),
              FilterButtons(),
              k16SizeBox,
              TodoInput(),
              k16SizeBox,
              TodoList(),
            ],
          ),
        ),
      ],
    );
  }
}

class TodoInput extends StatefulWidget {
  const TodoInput({super.key});

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  final controller = TextEditingController(text: inputTextBeacon.peek());
  final focus = FocusNode();

  @override
  void initState() {
    controller.addListener(() {
      inputTextBeacon.value = controller.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: k24Text,
      focusNode: focus,
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Todo',
      ),
      onSubmitted: (_) {
        addTodo();
        controller.clear();
        focus.requestFocus();
      },
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = filteredTodos.watch(context);
    return Expanded(
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoItem(todo: todo);
        },
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.description, style: k24Text),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          todosBeacon.value =
              todosBeacon.peek().where((e) => e.id != todo.id).toList();
        },
      ),
      leading: Checkbox(
        value: todo.completed,
        onChanged: (value) {
          if (value == null) return;
          todosBeacon.value = todosBeacon.peek().map((e) {
            if (e.id == todo.id) {
              return Todo(
                id: e.id,
                description: e.description,
                completed: value,
              );
            }
            return e;
          }).toList();
        },
      ),
    );
  }
}

class FilterButtons extends StatelessWidget {
  const FilterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final current = filterBeacon.watch(context);
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        3,
        (int index) {
          return ChoiceChip(
            label: Text(Filter.values[index].name, style: k24Text),
            selected: current.index == index,
            onSelected: (bool selected) {
              if (!selected) return;
              filterBeacon.value = Filter.values[index];
            },
          );
        },
      ).toList(),
    );
  }
}

@immutable
class Todo {
  const Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}
