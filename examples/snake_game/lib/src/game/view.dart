import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:state_beacon/state_beacon.dart';
import 'package:snake_game/src/game/controller.dart';

import 'models.dart';

final gameControllerRef = Ref.scoped((_) => GameController());

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final controller = gameControllerRef(context);
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              controller.changeDirection(Direction.up);
            case LogicalKeyboardKey.arrowDown:
              controller.changeDirection(Direction.down);
            case LogicalKeyboardKey.arrowLeft:
              controller.changeDirection(Direction.left);
            case LogicalKeyboardKey.arrowRight:
              controller.changeDirection(Direction.right);
            case LogicalKeyboardKey.space:
              final status = controller.status.peek();
              if (status == GameStatus.paused) {
                controller.resumeGame();
              } else if (status == GameStatus.playing) {
                controller.pauseGame();
              }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Snake Game'),
          centerTitle: true,
          elevation: 2,
        ),
        body: const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScoreWidget(),
                SizedBox(height: 16),
                GameBoard(),
                SizedBox(height: 16),
                GameControls(),
                SizedBox(height: 8),
                InstructionsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = gameControllerRef(context);
    final score = controller.score.watch(context);
    final status = controller.status.watch(context);
    final theme = Theme.of(context);

    String statusText = switch (status) {
      GameStatus.playing => 'Score: $score',
      GameStatus.paused => 'PAUSED - Score: $score',
      GameStatus.gameOver => 'GAME OVER - Final Score: $score',
    };

    Color statusColor = switch (status) {
      GameStatus.playing => theme.colorScheme.primary,
      GameStatus.paused => Colors.orange,
      GameStatus.gameOver => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.titleLarge?.copyWith(
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
    final controller = gameControllerRef(context);
    final snake = controller.snake.watch(context);
    final food = controller.food.watch(context);
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth - 32).clamp(200.0, 600.0);
    final cellSize = boardSize / gridSize;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 2),
      ),
      child: Stack(
        children: [
          for (final position in snake)
            Positioned(
              left: position.x * cellSize,
              top: position.y * cellSize,
              child: Container(
                width: cellSize - 1,
                height: cellSize - 1,
                decoration: BoxDecoration(
                  color: position == snake.first ? Colors.green.shade700 : Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Positioned(
            left: food.x * cellSize,
            top: food.y * cellSize,
            child: Container(
              width: cellSize - 1,
              height: cellSize - 1,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(cellSize / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = gameControllerRef(context);
    final status = controller.status.watch(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 240,
      child: Column(
        children: [
          if (status == GameStatus.paused || status == GameStatus.gameOver) ...[
            FilledButton.icon(
              onPressed: controller.startGame,
              icon: const Icon(Icons.play_arrow),
              label: Text(status == GameStatus.gameOver ? 'New Game' : 'Start Game'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
          if (status == GameStatus.playing) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: controller.pauseGame,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: controller.startGame,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton.filled(
                      onPressed: () => controller.changeDirection(Direction.up),
                      icon: const Icon(Icons.arrow_upward),
                      iconSize: 32,
                    ),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: () => controller.changeDirection(Direction.left),
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 32,
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => controller.changeDirection(Direction.down),
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 32,
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => controller.changeDirection(Direction.right),
                          icon: const Icon(Icons.arrow_forward),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class InstructionsWidget extends StatelessWidget {
  const InstructionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Controls',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Arrow Keys: Move • Space: Pause/Resume',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}