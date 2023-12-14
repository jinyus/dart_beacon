import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_beacon/state_beacon.dart';
import 'package:vgv_best_practices/counter/counter.dart';
import 'package:vgv_best_practices/l10n/l10n.dart';

// You could create a private final instance of the controller here instead of
// using Provider but that would make mocking more difficult/impossible.
// final _controller = CounterController();

// You could also use a dependency injection package like get_it to provide the
// controller to the page, but that would make the instance globally accessible,
// which is considered bad practice.

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (BuildContext context) => CounterController(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.counterAppBarTitle)),
      body: const Center(
        child: Column(
          children: [
            CounterText(),
            DoubledText(),
            TripledText(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterController>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterController>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // not need to watch the controller, because it is a singleton
    final controller = context.read<CounterController>();

    // watch the beacon for changes
    final count = controller.count.watch(context);

    return Text('$count', style: theme.textTheme.displayLarge);
  }
}

class DoubledText extends StatelessWidget {
  const DoubledText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // not need to watch the controller, because it is a singleton
    final controller = context.read<CounterController>();

    // watch the beacon for changes
    final doubleCount = controller.doubleCount.watch(context);

    return Text('$doubleCount', style: theme.textTheme.displayLarge);
  }
}

class TripledText extends StatelessWidget {
  const TripledText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // not need to watch the controller, because it is a singleton
    final controller = context.read<CounterController>();

    // watch the beacon for changes
    final tripleCount = controller.tripleCount.watch(context);

    final text = switch (tripleCount) {
      AsyncData(:final value) => value,
      AsyncError(:final error) => error.toString(),
      _ => 'fetching triple count...',
    };

    return Text('$text', style: theme.textTheme.displayLarge);
  }
}
