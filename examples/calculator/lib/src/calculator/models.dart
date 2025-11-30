enum Operation {
  add('+'),
  subtract('-'),
  multiply('×'),
  divide('÷');

  const Operation(this.symbol);
  final String symbol;
}

sealed class CalculatorAction {}

class NumberAction extends CalculatorAction {
  final String digit;
  NumberAction(this.digit);
}

class OperationAction extends CalculatorAction {
  final Operation operation;
  OperationAction(this.operation);
}

class EqualsAction extends CalculatorAction {}

class ClearAction extends CalculatorAction {}

class DeleteAction extends CalculatorAction {}

class DecimalAction extends CalculatorAction {}
