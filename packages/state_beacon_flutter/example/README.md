source code with tests: [examples/counter/lib/main.dart](https://github.com/zupat/dart_beacon/blob/main/examples/counter/lib/main.dart)

```dart
class Controller extends BeaconController {
  late final count = B.writable(0);

  void increment() => count.value++;
  void decrement() => count.value--;
}

final countController = Controller();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('State Beacon Counter without LiteRef'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CounterText()),
        floatingActionButton: const Buttons(),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final count = countController.count;
    final theme = Theme.of(context);
    return Text('$count', style: theme.textTheme.displayLarge);
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton.filled(
          onPressed: countController.increment,
          icon: const Icon(Icons.add),
          iconSize: 32,
        ),
        const SizedBox(height: 8),
        IconButton.filled(
          onPressed: countController.decrement,
          icon: const Icon(Icons.remove),
          iconSize: 32,
        ),
      ],
    );
  }
}
```
