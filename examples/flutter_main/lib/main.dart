// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:example/counter/counter.dart';
import 'package:example/infinite_list/infinite_list.dart';
import 'package:example/konami/konami.dart';
import 'package:example/search/search.dart';
import 'package:example/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

final brightness = Ref.scoped((_) => Beacon.writable(Brightness.light));

void main() => runApp(LiteRefScope(child: const MyApp()));

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
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: brightness.watch(context) == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = brightness.watch(context) == Brightness.dark;
    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: const Text('Beacon Examples'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.onetwothree)),
              Tab(icon: Icon(Icons.abc)),
              Tab(icon: Icon(Icons.edit)),
              Tab(icon: Icon(Icons.search)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            CounterPage(),
            KonamiPage(),
            TodoPage(),
            SearchPage(),
            InfiniteListPage(),
          ],
        ),
        floatingActionButton: IconButton(
          onPressed: () {
            brightness.of(context).value =
                isDark ? Brightness.light : Brightness.dark;
          },
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    );
  }
}
