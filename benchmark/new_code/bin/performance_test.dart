import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

typedef VoidCallback = void Function();

class BeaconBench extends BenchmarkBase {
  BeaconBench(super.name);

  @override
  void exercise() {
    for (var i = 0; i < 1000; i++) {
      run();
    }
  }
}

class BroadPropagationBenchmark extends BeaconBench {
  BroadPropagationBenchmark() : super('BroadPropagationBenchmark');

  final head = Beacon.writable(0);
  late ReadableBeacon<int> last = head;
  var callCount = 0;

  @override
  void setup() {
    for (int i = 0; i < 50; i++) {
      final current = Beacon.derived(() => head.value + i);
      final current2 = Beacon.derived(() => current.value + 1);

      Beacon.effect(() {
        current2.value;
        callCount++;
      });
      BeaconScheduler.flush();

      last = current2;
    }
  }

  @override
  void teardown() {}

  @override
  void run() {
    head.value = 1;
    BeaconScheduler.flush();

    callCount = 0;

    for (int i = 0; i < 50; i++) {
      head.value = i;
      BeaconScheduler.flush();

      final count = (i + 1) * 50;
      if (last.value != i + 50 || callCount != count) {
        print(
            'last value: ${last.value}, expected: ${i + 50}, callCount: $callCount, expected: $count');
        exit(1);
      }
    }
  }
}

class DeepPropagationBenchmark extends BeaconBench {
  DeepPropagationBenchmark() : super('DeepPropagationBenchmark');

  late final WritableBeacon<int> head;
  late ReadableBeacon<int> current;
  var callCount = 0;
  static const len = 50;

  @override
  void setup() {
    head = Beacon.writable(0);
    current = head;

    for (int i = 0; i < len; i++) {
      final c = current;
      current = Beacon.derived(() => c.value + 1);
    }

    Beacon.effect(() {
      current.value;
      callCount++;
    });
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    head.value = 1;
    BeaconScheduler.flush();

    callCount = 0;

    for (int i = 0; i < 50; i++) {
      head.value = i;
      BeaconScheduler.flush();

      if (current.value != len + i) {
        print('current value: ${current.value}, expected: ${len + i}');
        exit(1);
      }
    }

    if (callCount != 50) {
      print('callCount: $callCount, expected: 50');
      exit(1);
    }
  }
}

class AvoidablePropagationBenchmark extends BeaconBench {
  AvoidablePropagationBenchmark() : super('AvoidablePropagationBenchmark');

  late final WritableBeacon<int> head;
  late final ReadableBeacon<int> c1;
  late final ReadableBeacon<int> c2;
  late final ReadableBeacon<int> c3;
  late final ReadableBeacon<int> c4;
  late final ReadableBeacon<int> c5;
  var callCount = 0;

  void busy() {
    // ignore: unused_local_variable
    int a = 0;
    for (int i = 0; i < 100; i++) {
      a++;
    }
  }

  @override
  void setup() {
    head = Beacon.writable(0);
    c1 = Beacon.derived(() => head.value);
    c2 = Beacon.derived(() {
      c1.value;
      return 0;
    });
    c3 = Beacon.derived(() {
      busy();
      return c2.value + 1;
    });
    c4 = Beacon.derived(() => c3.value + 2);
    c5 = Beacon.derived(() => c4.value + 3);

    Beacon.effect(() {
      callCount++;
      c5.value;
      busy();
    });
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    head.value = 1;
    BeaconScheduler.flush();

    if (c5.value != 6) {
      print('c5 value: ${c5.value}, expected: 6');
      exit(1);
    }

    for (int i = 0; i < 1000; i++) {
      head.value = i;
      BeaconScheduler.flush();
      if (c5.value != 6) {
        print('c5 value: ${c5.value}, expected: 6 at iteration $i');
        exit(1);
      }
    }

    if (callCount != 1) {
      print('callCount: $callCount, expected: 1');
      exit(1);
    }
  }
}

class DiamondBenchmark extends BeaconBench {
  DiamondBenchmark() : super('DiamondBenchmark');

  static const width = 5;
  late final WritableBeacon<int> head;
  late final List<ReadableBeacon<int>> current;
  late final ReadableBeacon<int> sum;
  var callCount = 0;

  @override
  void setup() {
    head = Beacon.writable(0);
    current = [];
    for (int i = 0; i < width; i++) {
      current.add(
        Beacon.derived(() => head.value + 1),
      );
    }

    sum = Beacon.derived(() {
      return current.fold(0, (prev, x) => prev + x.value);
    });

    Beacon.effect(() {
      sum.value;
      callCount++;
    });
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    head.value = 1;
    BeaconScheduler.flush();

    if (sum.value != 2 * width) {
      print('sum value: ${sum.value}, expected: ${2 * width}');
      exit(1);
    }

    callCount = 0;
    for (int i = 0; i < 500; i++) {
      head.value = i;
      BeaconScheduler.flush();

      final expected = (i + 1) * width;
      if (sum.value != expected) {
        print('sum value: ${sum.value}, expected: $expected at iteration $i');
        exit(1);
      }
    }

    if (callCount != 500) {
      print('callCount: $callCount, expected: 500');
      exit(1);
    }
  }
}

class MuxBenchmark extends BeaconBench {
  MuxBenchmark() : super('MuxBenchmark');

  late final List<WritableBeacon<int>> heads;
  late final ReadableBeacon<Map<int, int>> mux;
  late final List<ReadableBeacon<int>> splited;
  var sum = 0;

  @override
  void setup() {
    heads = List.generate(100, (_) => Beacon.writable(0));
    mux = Beacon.derived(() {
      return Map.fromEntries(
        heads.map((h) => h.value).toList().asMap().entries,
      );
    });

    splited = heads
        .asMap()
        .entries
        .map((e) => Beacon.derived(() => mux.value[e.key]!))
        .map((x) => Beacon.derived(() => x.value + 1))
        .toList();

    for (final x in splited) {
      Beacon.effect(() => sum += x.value);
    }
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    sum = 0;

    for (int i = 0; i < 10; i++) {
      heads[i].value = i;
      BeaconScheduler.flush();

      if (splited[i].value != i + 1) {
        print('splited[$i] value: ${splited[i].value}, expected: ${i + 1}');
        exit(1);
      }
    }

    if (sum != 54) {
      print('sum: $sum, expected: 54');
      exit(1);
    }
    sum = 0;

    for (int i = 0; i < 10; i++) {
      heads[i].value = i * 2;
      BeaconScheduler.flush();

      if (splited[i].value != i * 2 + 1) {
        print('splited[$i] value: ${splited[i].value}, expected: ${i * 2 + 1}');
        exit(1);
      }
    }

    if (sum != 99) {
      print('sum: $sum, expected: 99');
      exit(1);
    }
  }
}

class RepeatedObserversBenchmark extends BeaconBench {
  RepeatedObserversBenchmark() : super('RepeatedObserversBenchmark');

  static const size = 30;
  late final WritableBeacon<int> head;
  late final ReadableBeacon<int> current;
  var callCount = 0;

  @override
  void setup() {
    head = Beacon.writable(0);
    current = Beacon.derived(() {
      int result = 0;
      for (int i = 0; i < size; i++) {
        result += head.value;
      }
      return result;
    });

    Beacon.effect(() {
      current.value;
      callCount++;
    });
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    head.value = 1;
    BeaconScheduler.flush();

    if (current.value != size) {
      print('current value: ${current.value}, expected: $size');
      exit(1);
    }

    callCount = 0;
    for (int i = 0; i < 100; i++) {
      head.value = i;
      BeaconScheduler.flush();

      final expected = i * size;
      if (current.value != expected) {
        print(
            'current value: ${current.value}, expected: $expected at iteration $i');
        exit(1);
      }
    }

    if (callCount != 100) {
      print('callCount: $callCount, expected: 100');
      exit(1);
    }
  }
}

class TriangleBenchmark extends BeaconBench {
  TriangleBenchmark() : super('TriangleBenchmark');

  static const width = 10;
  late final WritableBeacon<int> head;
  late final List<ReadableBeacon<int>> list;
  late final ReadableBeacon<int> sum;
  var callCount = 0;

  @override
  void setup() {
    head = Beacon.writable(0);
    ReadableBeacon<int> current = head;
    list = <ReadableBeacon<int>>[];

    for (int i = 0; i < width; i++) {
      final c = current;
      list.add(current);
      current = Beacon.derived(() => c.value + 1);
    }

    sum = Beacon.derived(() {
      return list.map((x) => x.value).reduce((a, b) => a + b);
    });

    Beacon.effect(() {
      sum.value;
      callCount++;
    });
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    final constant = _count(width);
    head.value = 1;
    BeaconScheduler.flush();

    if (sum.value != constant) {
      print('sum value: ${sum.value}, expected: $constant');
      exit(1);
    }

    callCount = 0;
    for (int i = 0; i < 100; i++) {
      head.value = i;
      BeaconScheduler.flush();

      final expected = constant - width + i * width;
      if (sum.value != expected) {
        print('sum value: ${sum.value}, expected: $expected at iteration $i');
        exit(1);
      }
    }

    if (callCount != 100) {
      print('callCount: $callCount, expected: 100');
      exit(1);
    }
  }

  int _count(int number) {
    return List.generate(number, (i) => i + 1).reduce((x, y) => x + y);
  }
}

class UnstableBenchmark extends BeaconBench {
  UnstableBenchmark() : super('UnstableBenchmark');

  late final WritableBeacon<int> head;
  late final ReadableBeacon<int> double;
  late final ReadableBeacon<int> inverse;
  late final ReadableBeacon<int> current;
  var callCount = 0;

  @override
  void setup() {
    head = Beacon.writable(0);
    double = Beacon.derived(() => head.value * 2);
    inverse = Beacon.derived(() => -head.value);
    current = Beacon.derived(() {
      var result = 0;
      for (int i = 0; i < 20; i++) {
        result += head.value % 2 == 1 ? double.value : inverse.value;
      }
      return result;
    });

    Beacon.effect(() {
      current.value;
      callCount++;
    });
    BeaconScheduler.flush();
  }

  @override
  void teardown() {}

  @override
  void run() {
    head.value = 1;
    BeaconScheduler.flush();

    if (current.value != 40) {
      print('current value: ${current.value}, expected: 40');
      exit(1);
    }

    callCount = 0;

    for (int i = 0; i < 100; i++) {
      head.value = i;
      BeaconScheduler.flush();

      final expected = (i % 2 == 1 ? i * 2 : -i) * 20;
      if (current.value != expected) {
        print(
            'current value: ${current.value}, expected: $expected at iteration $i');
        exit(1);
      }
    }

    if (callCount != 100) {
      print('callCount: $callCount, expected: 100');
      exit(1);
    }
  }
}

void main(List<String> args) {
  BroadPropagationBenchmark().report();
  DeepPropagationBenchmark().report();
  AvoidablePropagationBenchmark().report();
  DiamondBenchmark().report();
  MuxBenchmark().report();
  RepeatedObserversBenchmark().report();
  TriangleBenchmark().report();
  UnstableBenchmark().report();
}
