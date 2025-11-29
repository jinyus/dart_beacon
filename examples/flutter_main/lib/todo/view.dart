part of 'todo.dart';

final todoControllerRef = Ref.scoped((ctx) => TodoController());
final todoFocusRef = Ref.scoped((ctx) => FocusNode());

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
              k16SizeBox,
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

class TodoInput extends StatelessWidget {
  const TodoInput({super.key});

  @override
  Widget build(BuildContext context) {
    final todoController = todoControllerRef.of(context);
    final inputTextBeacon = todoController.inputTextBeacon;
    final focus = todoFocusRef.of(context);

    return TextField(
      key: const Key('todoInput'),
      style: k24Text,
      focusNode: focus,
      controller: inputTextBeacon.controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Todo',
      ),
      onSubmitted: (_) {
        todoController.addTodo();
        inputTextBeacon.clear();
        focus.requestFocus();
      },
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = todoControllerRef.select(context, (c) => c.filteredTodos);
    return Expanded(
      child: ListView.separated(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoItem(todo: todo);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 5),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final controller = todoControllerRef(context);

    return ListTile(
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
      title: Text(todo.description, style: k24Text),
      trailing: IconButton(
        key: ValueKey('${todo.id} delete button'),
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => controller.deleteTodo(todo.id),
      ),
      leading: Checkbox(
        key: ValueKey('${todo.id} checkbox'),
        value: todo.completed,
        onChanged: (value) {
          if (value == null) return;
          controller.toggleTodo(value, todo.id);
        },
      ),
    );
  }
}

class FilterButtons extends StatelessWidget {
  const FilterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final filterBeacon = todoControllerRef(context).filterBeacon;
    final current = filterBeacon.watch(context);
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        3,
        (int index) {
          return ChoiceChip(
            key: ValueKey('${Filter.values[index]} button'),
            label: Text(Filter.values[index].name, style: k24Text),
            selected: current.index == index,
            onSelected: (bool selected) {
              if (!selected) return;
              filterBeacon.value = Filter.values[index];
            },
          );
        },
      ),
    );
  }
}
