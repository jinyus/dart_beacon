import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe App')),
      body: const Center(
        child: Text('Welcome to Recipe App', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
