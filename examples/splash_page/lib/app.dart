import 'package:flutter/material.dart';
import 'package:splash_page/const/theme.dart';
import 'package:splash_page/pages/home_page.dart';
import 'package:splash_page/setup_dependencies.dart';
import 'package:state_beacon/state_beacon.dart';

final _startUpBeacon = Ref.scoped((_) => Beacon.future(startUp));

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: switch (_startUpBeacon.watch(context)) {
        AsyncData() => const Home(),
        AsyncError e => SplashScreen(errorText: e.error.toString()),
        _ => const SplashScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.errorText});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 64),
            const SizedBox(height: 16),
            if (errorText != null)
              SizedBox(
                // height: 200,
                child: Column(
                  children: [
                    Text(errorText!),
                    ElevatedButton(
                      onPressed: () {
                        _startUpBeacon.read(context).reset();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
