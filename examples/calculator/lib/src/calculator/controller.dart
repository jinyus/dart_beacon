import 'package:state_beacon/state_beacon.dart';

import 'models.dart';

class CalculatorController extends BeaconController {
  late final display = B.writable('0');

  late final lastAction = B.writable<CalculatorAction>(ClearAction());

  double? _firstOperand;
  Operation? _operation;
  bool _shouldResetDisplay = false;

  CalculatorController() {
    lastAction.subscribe(_handleAction);
  }

  void _handleAction(CalculatorAction action) {
    switch (action) {
      case ClearAction():
        display.value = '0';
      case NumberAction():
        final current = display.peek();
        if (current == '0' || _shouldResetDisplay) {
          _shouldResetDisplay = false;
          display.value = action.digit;
        } else {
          display.value = current + action.digit;
        }
      case DecimalAction():
        final current = display.peek();
        if (_shouldResetDisplay) {
          _shouldResetDisplay = false;
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
        if (_operation != null && _firstOperand != null) {
          final second = double.tryParse(display.peek()) ?? 0;
          final result = _calculate(_firstOperand!, second, _operation!);
          _firstOperand = result;
          _operation = null;
          _shouldResetDisplay = true;
          display.value = _formatResult(result);
        }
    }
  }

  void inputNumber(String digit) {
    lastAction.value = NumberAction(digit);
  }

  void inputOperation(Operation op) {
    final currentValue = double.tryParse(display.peek()) ?? 0;

    if (_firstOperand != null && _operation != null && !_shouldResetDisplay) {
      final result = _calculate(_firstOperand!, currentValue, _operation!);
      _firstOperand = result;
      display.value = _formatResult(result);
    } else {
      _firstOperand = currentValue;
    }

    _operation = op;
    _shouldResetDisplay = true;
    lastAction.value = OperationAction(op);
  }

  void calculate() {
    lastAction.value = EqualsAction();
  }

  void clear() {
    _firstOperand = null;
    _operation = null;
    _shouldResetDisplay = false;
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