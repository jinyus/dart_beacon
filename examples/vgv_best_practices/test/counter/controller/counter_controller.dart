import 'package:flutter_test/flutter_test.dart';

import 'package:vgv_best_practices/counter/counter.dart';

void main() {
  group('CounterCubit', () {
    late CounterController counterController;

    setUp(() {
      counterController = CounterController();
    });

    test('initial state is 0', () {
      expect(counterController.count.value, equals(0));
    });

    test('value is 1 when increment is called', () {
      counterController.increment();
      expect(counterController.count.value, equals(1));
    });

    test('value is -1 when decrement is called', () {
      counterController.decrement();
      expect(counterController.count.value, equals(-1));
    });
  });
}
