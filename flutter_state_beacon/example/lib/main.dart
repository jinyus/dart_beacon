// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:example/counter_page.dart';
import 'package:example/search_page.dart';
import 'package:example/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_beacon/flutter_state_beacon.dart';

final brightness = Beacon.writable(Brightness.light);

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
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: const Text('Beacon Examples'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.onetwothree)),
              Tab(icon: Icon(Icons.edit)),
              Tab(icon: Icon(Icons.search)),
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
        floatingActionButton: IconButton(
          onPressed: () {
            brightness.value = isDark ? Brightness.light : Brightness.dark;
          },
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        ),
      ),
    );
  }
}
