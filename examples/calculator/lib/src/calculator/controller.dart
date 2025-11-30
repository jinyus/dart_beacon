import 'package:state_beacon/state_beacon.dart';

import 'models.dart';

class CalculatorController extends BeaconController {
  late final lastAction = B.writable<CalculatorAction>(ClearAction());

  late final firstOperand = B.writable<double?>(null);
  late final operation = B.writable<Operation?>(null);
  late final display = B.writable('0');

  late final shouldResetDisplay = B.derived(() {
    final action = lastAction.value;
    final prevAction = lastAction.previousValue;
    
    if (action is NumberAction || action is DecimalAction) {
      return prevAction is OperationAction || prevAction is EqualsAction;
    }
    return false;
  });

  CalculatorController() {
    lastAction.subscribe(_handleAction);
  }

  void _handleAction(CalculatorAction action) {
    switch (action) {
      case ClearAction():
        display.value = '0';
      case NumberAction():
        final current = display.peek();
        if (current == '0' || shouldResetDisplay.peek()) {
          display.value = action.digit;
        } else {
          display.value = current + action.digit;
        }
      case DecimalAction():
        final current = display.peek();
        if (shouldResetDisplay.peek()) {
          display.value = '0.';
        } else if (!current.contains('.')) {
          display.value = '$current.';
        }
      case DeleteAction():
        final current = display.peek();
        if (current.length <= 1) {
          display.value = '0';
        } else {
          display.value = current.substring(0, current.length - 1);
        }
      case OperationAction():
        break;
      case EqualsAction():
        if (operation.peek() != null && firstOperand.peek() != null) {
          final second = double.tryParse(display.peek()) ?? 0;
          final result = _calculate(
            firstOperand.peek()!,
            second,
            operation.peek()!,
          );
          firstOperand.value = result;
          operation.value = null;
          display.value = _formatResult(result);
        }
    }
  }

  void inputNumber(String digit) {
    lastAction.value = NumberAction(digit);
  }

  void inputOperation(Operation op) {
    final currentValue = double.tryParse(display.peek()) ?? 0;
    final prevAction = lastAction.peek();

    if (firstOperand.peek() != null &&
        operation.peek() != null &&
        prevAction is! OperationAction &&
        prevAction is! EqualsAction) {
      final result = _calculate(
        firstOperand.peek()!,
        currentValue,
        operation.peek()!,
      );
      firstOperand.value = result;
    } else {
      firstOperand.value = currentValue;
    }

    operation.value = op;
    lastAction.value = OperationAction(op);
  }

  void calculate() {
    lastAction.value = EqualsAction();
  }

  void clear() {
    firstOperand.value = null;
    operation.value = null;
    lastAction.value = ClearAction();
  }

  void delete() {
    lastAction.value = DeleteAction();
  }

  void inputDecimal() {
    lastAction.value = DecimalAction();
  }

  double _calculate(double first, double second, Operation operation) {
    return switch (operation) {
      Operation.add => first + second,
      Operation.subtract => first - second,
      Operation.multiply => first * second,
      Operation.divide => second != 0 ? first / second : 0,
    };
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}