part of 'todo.dart';

final todoControllerRef = Ref.scoped((ctx) => TodoController());

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

class TodoInput extends StatefulWidget {
  const TodoInput({super.key});

  @override
  State<TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  late final TodoController controller;
  late final textController = TextEditingController(
    text: controller.inputTextBeacon.peek(),
  );
  final focus = FocusNode();

  @override
  void initState() {
    controller = todoControllerRef.read(context);
    textController.addListener(() {
      controller.inputTextBeacon.value = textController.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: k24Text,
      focusNode: focus,
      controller: textController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Todo',
      ),
      onSubmitted: (_) {
        controller.addTodo();
        textController.clear();
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
    final todosBeacon = todoControllerRef(context).todosBeacon;
    return ListTile(
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
      title: Text(todo.description, style: k24Text),
      trailing: IconButton(
        key: ValueKey('${todo.id} delete button'),
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          todosBeacon.removeWhere((e) => e.id == todo.id);
        },
      ),
      leading: Checkbox(
        value: todo.completed,
        onChanged: (value) {
          if (value == null) return;
          todosBeacon.mapInPlace((e) {
            if (e.id == todo.id) {
              return Todo(
                id: e.id,
                description: e.description,
                completed: value,
              );
            }
            return e;
          });
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
