// ignore_for_file: inference_failure_on_instance_creation

import 'package:state_beacon/state_beacon.dart';

class CounterController {
  final _count = Beacon.writable(0);

  /// automatically updates when `count` changes
  late final _doubleCount = Beacon.derived(() => _count.value * 2);

  /// automatically recomputes when `count` changes.
  /// imagine count being a pageNumber
  /// and `fetchTripleCount` being `fetchPosts()`
  late final _tripleCount = Beacon.derivedFuture(
    () => Repository.fetchTripleCount(count.value),
  );

  // expose the beacons as immutable so consumers can't modify them
  ReadableBeacon<int> get count => _count;
  ReadableBeacon<int> get doubleCount => _doubleCount;
  FutureBeacon<int> get tripleCount => _tripleCount;

  void increment() => _count.increment();
  void decrement() => _count.decrement();
}

class Repository {
  static Future<int> fetchTripleCount(int count) async {
    await Future.delayed(const Duration(seconds: 1));
    return count * 3;
  }
}
