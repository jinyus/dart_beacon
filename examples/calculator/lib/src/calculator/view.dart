import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

import 'controller.dart';
import 'models.dart';

final calculatorControllerRef = Ref.scoped((_) => CalculatorController());

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: DisplayPanel()),
              SizedBox(height: 16),
              ButtonPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayPanel extends StatelessWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = calculatorControllerRef(context);
    final display = controller.display.watch(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              display,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
                letterSpacing: -2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonPanel extends StatelessWidget {
  const ButtonPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = calculatorControllerRef(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CalculatorButton(
                text: 'C',
                onPressed: controller.clear,
                color: ButtonColor.function,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: CalculatorButton(
                text: '⌫',
                onPressed: controller.delete,
                color: ButtonColor.function,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: Operation.divide.symbol,
                onPressed: () => controller.inputOperation(Operation.divide),
                color: ButtonColor.operation,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalculatorButton(
                text: '7',
                onPressed: () => controller.inputNumber('7'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '8',
                onPressed: () => controller.inputNumber('8'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '9',
                onPressed: () => controller.inputNumber('9'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: Operation.multiply.symbol,
                onPressed: () => controller.inputOperation(Operation.multiply),
                color: ButtonColor.operation,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalculatorButton(
                text: '4',
                onPressed: () => controller.inputNumber('4'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '5',
                onPressed: () => controller.inputNumber('5'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '6',
                onPressed: () => controller.inputNumber('6'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: Operation.subtract.symbol,
                onPressed: () => controller.inputOperation(Operation.subtract),
                color: ButtonColor.operation,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalculatorButton(
                text: '1',
                onPressed: () => controller.inputNumber('1'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '2',
                onPressed: () => controller.inputNumber('2'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '3',
                onPressed: () => controller.inputNumber('3'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: Operation.add.symbol,
                onPressed: () => controller.inputOperation(Operation.add),
                color: ButtonColor.operation,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CalculatorButton(
                text: '0',
                onPressed: () => controller.inputNumber('0'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '.',
                onPressed: controller.inputDecimal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalculatorButton(
                text: '=',
                onPressed: controller.calculate,
                color: ButtonColor.equals,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum ButtonColor { number, operation, function, equals }

class CalculatorButton extends StatelessWidget {
  const CalculatorButton({
    required this.text,
    required this.onPressed,
    this.color = ButtonColor.number,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;
  final ButtonColor color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBackgroundColor() {
      return switch (color) {
        ButtonColor.number => theme.colorScheme.surfaceContainerHighest,
        ButtonColor.operation => theme.colorScheme.secondaryContainer,
        ButtonColor.function => theme.colorScheme.errorContainer,
        ButtonColor.equals => theme.colorScheme.primaryContainer,
      };
    }

    Color getTextColor() {
      return switch (color) {
        ButtonColor.number => theme.colorScheme.onSurface,
        ButtonColor.operation => theme.colorScheme.onSecondaryContainer,
        ButtonColor.function => theme.colorScheme.onErrorContainer,
        ButtonColor.equals => theme.colorScheme.onPrimaryContainer,
      };
    }

    return Material(
      color: getBackgroundColor(),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 72,
          alignment: Alignment.center,
          child: Text(
            text,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: getTextColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
