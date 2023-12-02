// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:example/counter_page.dart';
import 'package:example/search_page.dart';
import 'package:example/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_beacon/flutter_state_beacon.dart';

final brightness = Beacon.writable(Brightness.light);
final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final derivedFutureCounter = Beacon.derivedFuture(() async {
  final count = counter.value;
  return await counterFuture(count);
});

Future<String> counterFuture(int count) async {
  final count = counter.peek();
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
      title: 'Flutter Beacon Demo',
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: brightness.watch(context) == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: const Text('Beacon Examples'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.onetwothree),
              ),
              Tab(
                icon: Icon(Icons.edit),
              ),
              Tab(
                icon: Icon(Icons.search),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            CounterPage(),
            TodoPage(),
            SearchPage(),
          ],
        ),
        floatingActionButton: Builder(builder: (context) {
          final isDark = brightness.watch(context) == Brightness.dark;
          return IconButton(
            onPressed: () {
              brightness.value = isDark ? Brightness.light : Brightness.dark;
            },
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          );
        }),
      ),
    );
  }
}
// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         actions: [
//           Builder(builder: (context) {
//             final isDark = brightness.watch(context) == Brightness.dark;
//             return IconButton(
//               onPressed: () {
//                 brightness.value = isDark ? Brightness.light : Brightness.dark;
//               },
//               icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
//             );
//           }),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//               style: Theme.of(context).textTheme.headlineLarge,
//             ),
//             counter.watch(context) < 10 ? Counter() : Container(),
//             FutureCounter(),
//           ],
//         ),
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () => counter.value--,
//             tooltip: 'Decrement',
//             child: const Icon(Icons.remove),
//           ),
//           SizedBox(width: 10),
//           FloatingActionButton(
//             onPressed: () => counter.value++,
//             tooltip: 'Increment',
//             child: const Icon(Icons.add),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
