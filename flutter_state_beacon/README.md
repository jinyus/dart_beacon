# <center>Flutter State Beacon</center>

### A simple state management library flutter using beacons/signals

### Usage

Click [here](https://github.com/jinyus/flutter_state_beacon/blob/main/flutter_beacon/example/lib/main.dart) for the full code.

#### Create a beacon

```dart
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final derivedFutureCounter = Beacon.derivedFuture(() async {
  final count = counter.value;
  return await counterFuture(count);
});

Future<String> counterFuture(int count) async {
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
}
```

#### Watch it in a widget

```dart
class Counter extends StatelessWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      counter.watch(context).toString(),
      style: Theme.of(context).textTheme.headlineMedium!,
    );
  }
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (derivedFutureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v),
      AsyncError(error: final e) => Text('$e'),
      AsyncLoading() => const CircularProgressIndicator(),
    };
  }
}
```
