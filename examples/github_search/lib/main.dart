import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:github_search/features/search/ui/search_page.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  // BeaconObserver.useLogging();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  runApp(const LiteRefScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      home: const SearchPage(),
    );
  }
}
