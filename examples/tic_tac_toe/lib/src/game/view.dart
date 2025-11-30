import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';
import 'package:tic_tac_toe/src/game/controller.dart';

final gameControllerRef = Ref.scoped((_) => GameController());

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        elevation: 2,
      ),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GameStatusWidget(),
              SizedBox(height: 32),
              GameBoard(),
              SizedBox(height: 32),
              ResetButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class GameStatusWidget extends StatelessWidget {
  const GameStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = gameControllerRef.select(context, (c) => c.gameState);
    final theme = Theme.of(context);

    String statusText;
    Color statusColor;

    switch (state.status) {
      case GameStatus.playing:
        statusText = 'Player ${state.currentPlayer == Player.x ? 'X' : 'O'}\'s turn';
        statusColor = theme.colorScheme.primary;
      case GameStatus.xWins:
        statusText = 'Player X Wins!';
        statusColor = Colors.green;
      case GameStatus.oWins:
        statusText = 'Player O Wins!';
        statusColor = Colors.green;
      case GameStatus.draw:
        statusText = 'It\'s a Draw!';
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth - 64).clamp(200.0, 400.0);

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => GameCell(index: index),
      ),
    );
  }
}

class GameCell extends StatelessWidget {
  const GameCell({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = gameControllerRef(context);
    final state = controller.gameState.watch(context);
    final theme = Theme.of(context);
    final player = state.board[index];
    final isWinningCell = state.winningLine?.contains(index) ?? false;

    Color getCellColor() {
      if (isWinningCell) {
        return Colors.green.shade100;
      }
      if (player == Player.x) {
        return Colors.blue.shade100;
      }
      if (player == Player.o) {
        return Colors.red.shade100;
      }
      return theme.colorScheme.surfaceContainerHighest;
    }

    return Material(
      color: getCellColor(),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => controller.makeMove(index),
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: player == null
                ? const SizedBox.shrink()
                : Text(
                    player == Player.x ? 'X' : 'O',
                    key: ValueKey(player),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: player == Player.x ? Colors.blue : Colors.red,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = gameControllerRef(context);
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: controller.reset,
      icon: const Icon(Icons.refresh),
      label: const Text('New Game'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}