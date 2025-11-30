import 'package:calculator/src/calculator/controller.dart';
import 'package:calculator/src/calculator/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  late CalculatorController controller;

  setUp(() {
    controller = CalculatorController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('CalculatorController', () {
    group('Initial state', () {
      test('display should be 0', () {
        expect(controller.display.value, '0');
      });

      test('first operand should be null', () {
        expect(controller.firstOperand.value, null);
      });

      test('operation should be null', () {
        expect(controller.operation.value, null);
      });
    });

    group('Number input', () {
      test('inputting a single digit updates display', () {
        controller.inputNumber('5');
        BeaconScheduler.flush();
        expect(controller.display.value, '5');
      });

      test('inputting multiple digits concatenates them', () {
        controller.inputNumber('1');
        BeaconScheduler.flush();
        controller.inputNumber('2');
        BeaconScheduler.flush();
        controller.inputNumber('3');
        BeaconScheduler.flush();
        expect(controller.display.value, '123');
      });
    });

    group('Decimal input', () {
      test('inputting decimal on initial display shows 0.', () {
        controller.inputDecimal();
        BeaconScheduler.flush();
        expect(controller.display.value, '0.');
      });

      test('can input digits after decimal', () {
        controller.inputNumber('5');
        BeaconScheduler.flush();
        controller.inputDecimal();
        BeaconScheduler.flush();
        controller.inputNumber('2');
        BeaconScheduler.flush();
        expect(controller.display.value, '5.2');
      });
    });

    group('Clear operation', () {
      test('clear resets all state', () {
        controller.inputNumber('5');
        BeaconScheduler.flush();
        controller.inputOperation(Operation.add);
        BeaconScheduler.flush();
        controller.clear();
        BeaconScheduler.flush();
        expect(controller.display.value, '0');
        expect(controller.firstOperand.value, null);
        expect(controller.operation.value, null);
      });
    });

    group('Chained operations', () {
      test('5 + 3 + 2 = 10', () {
        controller.inputNumber('5');
        BeaconScheduler.flush();
        controller.inputOperation(Operation.add);
        BeaconScheduler.flush();
        controller.inputNumber('3');
        BeaconScheduler.flush();
        controller.inputOperation(Operation.add);
        BeaconScheduler.flush();
        controller.inputNumber('2');
        BeaconScheduler.flush();
        controller.calculate();
        BeaconScheduler.flush();
        expect(controller.display.value, '10');
      });
    });
  });
}
