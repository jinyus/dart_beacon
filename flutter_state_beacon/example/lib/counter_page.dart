import 'package:example/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_beacon/flutter_state_beacon.dart';

final count = Beacon.writable(0);

// the future will be recomputed whenever the counter changes
final derivedFutureCounter = Beacon.derivedFuture(() async {
  return await counterFuture(count.value);
});

Future<String> counterFuture(int count) async {
  if (count > 3) {
    throw Exception('Count($count) cannot be greater than 3');
  } else if (count < 0) {
    throw Exception('Count($count) cannot be negative');
  }
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final btnStyle = IconButton.styleFrom(
      minimumSize: const Size(100, 100),
      backgroundColor:
          Theme.of(context).buttonTheme.colorScheme!.primaryContainer,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.black),
      ),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Counter', style: TextStyle(fontSize: 48)),
        const Counter(),
        k16SizeBox,
        const FutureCounter(),
        k16SizeBox,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => count.value--,
              style: btnStyle,
            ),
            k16SizeBox,
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => count.value++,
              style: btnStyle,
            ),
          ],
        ),
      ],
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      count.watch(context).toString(),
      style: k40Text,
    );
  }
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.headlineSmall;
    return switch (derivedFutureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v, style: textTheme),
      AsyncError(error: final e) => Text('$e', style: textTheme),
      AsyncLoading() => const CircularProgressIndicator(),
    };
  }
}
