import 'package:flutter/material.dart';
import 'package:lite_ref/lite_ref.dart';
import 'package:state_beacon/state_beacon.dart';

class Controller extends BeaconController {
  late final _count = B.writable(0);

  // we expose it as a readable beacon
  // so it cannot be changed from outside the controller.
  ReadableBeacon<int> get count => _count;

  void increment() => _count.value++;
  void decrement() => _count.value--;
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
    final controller = countControllerRef.of(context);
    final count = controller.count.watch(context);
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
        FloatingActionButton(
          onPressed: controller.increment,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: controller.decrement,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }
}
