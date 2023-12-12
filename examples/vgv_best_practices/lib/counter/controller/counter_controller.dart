import 'package:state_beacon/state_beacon.dart';

class CounterController {
  final _count = Beacon.writable(0);

  ReadableBeacon<int> get count => _count;

  void increment() => _count.increment();
  void decrement() => _count.decrement();
}
