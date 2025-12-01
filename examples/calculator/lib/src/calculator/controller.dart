import 'package:state_beacon/state_beacon.dart';

import 'models.dart';

class CalculatorController extends BeaconController {
  late final lastAction = B.writable<CalculatorAction>(ClearAction());

  late final firstOperand = B.writable<double?>(null);
  late final operation = B.writable<Operation?>(null);

  late final shouldResetDisplay = B.derived(() {
    final action = lastAction.value;
    final prevAction = lastAction.previousValue;
    
    if (action is NumberAction || action is DecimalAction) {
      return prevAction is OperationAction || prevAction is EqualsAction;
    }
    return false;
  });

  late final display = B.derived(() {
    final action = lastAction.value;
    final current = display.previousValue ?? '0';
    
    switch (action) {
      case ClearAction():
        return '0';
      case NumberAction():
        if (current == '0' || shouldResetDisplay.value) {
          return action.digit;
        } else {
          return current + action.digit;
        }
      case DecimalAction():
        if (shouldResetDisplay.value) {
          return '0.';
        } else if (!current.contains('.')) {
          return '$current.';
        }
        return current;
      case DeleteAction():
        if (current.length <= 1) {
          return '0';
        } else {
          return current.substring(0, current.length - 1);
        }
      case OperationAction():
        return current;
      case EqualsAction():
        if (operation.value != null && firstOperand.value != null) {
          final second = double.tryParse(current) ?? 0;
          final result = _calculate(
            firstOperand.value!,
            second,
            operation.value!,
          );
          firstOperand.value = result;
          operation.value = null;
          return _formatResult(result);
        }
        return current;
    }
  });

  void inputNumber(String digit) {
    lastAction.value = NumberAction(digit);
  }

  void inputOperation(Operation op) {
    final currentValue = double.tryParse(display.value) ?? 0;
    final prevAction = lastAction.value;

    if (firstOperand.value != null &&
        operation.value != null &&
        prevAction is! OperationAction &&
        prevAction is! EqualsAction) {
      final result = _calculate(
        firstOperand.value!,
        currentValue,
        operation.value!,
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