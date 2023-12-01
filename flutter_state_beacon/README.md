# <center>Flutter State Beacon</center>

### A simple state management library flutter using beacons/signals

### Example

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
  if (count > 3) {
    throw Exception('Count($count) cannot be greater than 3');
  }
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: TextTheme(
          headlineMedium: TextStyle(fontSize: 48),
        ),
      ),
      themeMode: ThemeMode.light,
      home: const MyHomePage(title: 'Flutter Beacon Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            counter.watch(context) < 10 ? Counter() : Container(),
            FutureCounter(),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => counter.value--,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => counter.value++,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

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
    final textTheme = Theme.of(context).textTheme.headlineSmall;
    return switch (derivedFutureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v, style: textTheme),
      AsyncError(error: final e) => Text('$e', style: textTheme),
      AsyncLoading() => const CircularProgressIndicator(),
    };
  }
}
```
