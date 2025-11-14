import 'package:bench/benchmarks.dart';
import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

// This is used to profile the core library with the flutter profiler

final runningBeacon = Beacon.writable(false);
final resultBeacon = Beacon.writable<String>('Idle');

void runBench() {
  runningBeacon.value = true;
  Future.delayed(Duration(seconds: 1)).then((_) {
    try {
      resultBeacon.value = runAll();
    } finally {
      runningBeacon.value = false;
    }
  });
}

void main() {
  runApp(const LiteRefScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Bench'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: BenchText()),
        floatingActionButton: const Buttons(),
      ),
    );
  }
}

class BenchText extends StatelessWidget {
  const BenchText({super.key});

  @override
  Widget build(BuildContext context) {
    final running = runningBeacon.watch(context);
    final text = running ? 'Running' : resultBeacon.watch(context);
    final theme = Theme.of(context);
    return Text(text, style: theme.textTheme.displayLarge);
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    final running = runningBeacon.watch(context);

    return IconButton.filled(
      onPressed: running ? null : runBench,
      icon: const Icon(Icons.play_arrow),
      iconSize: 32,
    );
  }
}
