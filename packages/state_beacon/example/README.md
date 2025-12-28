source code with tests: [examples/counter/lib/main.dart](https://github.com/zupat/dart_beacon/blob/main/examples/counter/lib/main.dart)

```dart
class Controller extends BeaconController {
  late final count = B.writable(0);

  void increment() => count.value++;
  void decrement() => count.value--;
}

final countControllerRef = Ref.scoped((ctx) => Controller());

void main() {
  runApp(LiteRefScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lite Ref and State Beacon Counter'),
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
    final count = countControllerRef.select(context, (c) => c.count);
    final theme = Theme.of(context);
    return Text('$count', style: theme.textTheme.displayLarge);
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = countControllerRef.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton.filled(
          onPressed: controller.increment,
          icon: const Icon(Icons.add),
          iconSize: 32,
        ),
        const SizedBox(height: 8),
        IconButton.filled(
          onPressed: controller.decrement,
          icon: const Icon(Icons.remove),
          iconSize: 32,
        ),
      ],
    );
  }
}
```
