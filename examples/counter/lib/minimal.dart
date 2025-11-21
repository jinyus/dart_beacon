import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

final countControllerRef = Ref.scoped((ctx) => Beacon.writable(0));

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final count = countControllerRef.watch(context);
    return Scaffold(
      body: Center(child: Text('$count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => countControllerRef.of(context).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(const LiteRefScope(child: MaterialApp(home: CounterView())));
}
