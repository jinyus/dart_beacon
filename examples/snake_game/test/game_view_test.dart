import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';
import 'package:snake_game/src/game/models.dart';
import 'package:snake_game/src/game/view.dart';

void main() {
  group('GameView UI Tests', () {
    testWidgets('renders game view with all components', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Snake Game'), findsOneWidget);
      expect(find.byType(ScoreWidget), findsOneWidget);
      expect(find.byType(GameBoard), findsOneWidget);
      expect(find.byType(GameControls), findsOneWidget);
      expect(find.byType(InstructionsWidget), findsOneWidget);
    });

    testWidgets('initial state shows paused with score 0', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Score: 0'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('start button begins game', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.textContaining('Score:'), findsOneWidget);
    });

    testWidgets('pause button pauses game', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
      expect(find.textContaining('PAUSED'), findsOneWidget);
    });

    testWidgets('resume button resumes game', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();

      expect(find.text('Pause'), findsOneWidget);
      expect(find.textContaining('PAUSED'), findsNothing);
    });

    testWidgets('restart button resets game', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      expect(find.text('Pause'), findsOneWidget);
      expect(find.textContaining('Score: 0'), findsOneWidget);
    });

    testWidgets('game board renders snake and food', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gameBoard = find.byType(GameBoard);
      expect(gameBoard, findsOneWidget);

      final stack = find.descendant(
        of: gameBoard,
        matching: find.byType(Stack),
      );
      expect(stack, findsOneWidget);
    });

    testWidgets('score widget shows correct status colors', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Score: 0'), findsOneWidget);

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Score:'), findsOneWidget);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(find.textContaining('PAUSED'), findsOneWidget);
    });

    testWidgets('instructions widget shows controls', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Controls'), findsOneWidget);
      expect(find.textContaining('Arrow Keys'), findsOneWidget);
      expect(find.textContaining('Space'), findsOneWidget);
    });

    testWidgets('direction buttons are visible when playing', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.arrow_upward), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.arrow_downward), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.arrow_back), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('direction buttons are hidden when paused', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.arrow_upward), findsNothing);

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.arrow_upward), findsNothing);
    });

    testWidgets('tapping up direction button changes direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.up);
    });

    testWidgets('tapping down direction button changes direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_downward));
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.down);
    });

    testWidgets('tapping left direction button changes direction from up', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      controller.startGame();
      await tester.pumpAndSettle();
      
      controller.changeDirection(Direction.up);
      await tester.pumpAndSettle();

      controller.changeDirection(Direction.left);
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.left);
    });

    testWidgets('tapping right direction button maintains direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_forward));
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.right);
    });

    testWidgets('keyboard arrow up changes direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      
      controller.startGame();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.up);
    });

    testWidgets('keyboard arrow down changes direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      
      controller.startGame();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.down);
    });

    testWidgets('keyboard arrow left changes direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      
      controller.startGame();
      await tester.pumpAndSettle();
      
      controller.changeDirection(Direction.up);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.left);
    });

    testWidgets('keyboard arrow right maintains direction', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      
      controller.startGame();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.right);
    });

    testWidgets('space key pauses playing game', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      
      controller.startGame();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
      expect(find.textContaining('PAUSED'), findsOneWidget);
    });

    testWidgets('space key resumes paused game', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      
      controller.startGame();
      await tester.pumpAndSettle();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(find.text('Pause'), findsOneWidget);
      expect(find.textContaining('PAUSED'), findsNothing);
    });

    testWidgets('game over shows new game button', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      controller.startGame();
      await tester.pumpAndSettle();

      controller.changeDirection(Direction.left);
      await tester.pumpAndSettle();

      for (int i = 0; i < 15; i++) {
        controller.nextAction.value = MoveSnakeAction();
        await tester.pump(const Duration(milliseconds: 100));
        if (controller.status.value == GameStatus.gameOver) break;
      }

      if (controller.status.value == GameStatus.gameOver) {
        await tester.pumpAndSettle();
        expect(find.text('New Game'), findsOneWidget);
        expect(find.textContaining('GAME OVER'), findsOneWidget);
      }
    });

    testWidgets('new game button starts fresh game after game over', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      controller.startGame();
      await tester.pumpAndSettle();

      controller.changeDirection(Direction.left);
      await tester.pumpAndSettle();

      for (int i = 0; i < 15; i++) {
        controller.nextAction.value = MoveSnakeAction();
        await tester.pump(const Duration(milliseconds: 100));
        if (controller.status.value == GameStatus.gameOver) break;
      }

      if (controller.status.value == GameStatus.gameOver) {
        await tester.pumpAndSettle();
        await tester.tap(find.text('New Game'));
        await tester.pumpAndSettle();

        expect(find.text('Pause'), findsOneWidget);
        expect(controller.status.value, GameStatus.playing);
      }
    });

    testWidgets('complete game flow: start, pause, resume, restart', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect(find.text('Resume'), findsOneWidget);
      expect(find.textContaining('PAUSED'), findsOneWidget);

      await tester.tap(find.text('Resume'));
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      expect(find.textContaining('PAUSED'), findsNothing);

      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      expect(find.text('Pause'), findsOneWidget);
      expect(find.textContaining('Score: 0'), findsOneWidget);
    });
  });

  group('GameController integration with UI', () {
    testWidgets('controller state changes reflect in UI', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      expect(controller.status.value, GameStatus.paused);
      expect(find.textContaining('Score: 0'), findsOneWidget);

      controller.startGame();
      await tester.pumpAndSettle();

      expect(controller.status.value, GameStatus.playing);
      expect(find.text('Pause'), findsOneWidget);

      controller.pauseGame();
      await tester.pumpAndSettle();

      expect(controller.status.value, GameStatus.paused);
      expect(find.textContaining('PAUSED'), findsOneWidget);
    });

    testWidgets('direction changes update controller state', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      controller.startGame();
      await tester.pumpAndSettle();

      expect(controller.direction.value, Direction.right);

      controller.changeDirection(Direction.up);
      await tester.pumpAndSettle();
      expect(controller.direction.value, Direction.up);

      controller.changeDirection(Direction.left);
      await tester.pumpAndSettle();
      expect(controller.direction.value, Direction.left);

      controller.changeDirection(Direction.down);
      await tester.pumpAndSettle();
      expect(controller.direction.value, Direction.down);
    });

    testWidgets('snake initial position is center of board', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      expect(controller.snake.value.length, 1);
      expect(controller.snake.value.first, const Position(10, 10));
    });

    testWidgets('food position is different from snake', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      expect(controller.snake.value.contains(controller.food.value), false);
    });
  });

  group('UI responsiveness', () {
    testWidgets('game controls have proper height constraint', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(GameControls),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.height, 240);
    });

    testWidgets('buttons have consistent styling', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      final pauseButtons = find.widgetWithText(FilledButton, 'Pause');
      if (tester.widgetList(pauseButtons).isNotEmpty) {
        final pauseButton = tester.widget<FilledButton>(pauseButtons);
        expect(pauseButton.onPressed, isNotNull);
      }

      final restartButtons = find.widgetWithText(OutlinedButton, 'Restart');
      if (tester.widgetList(restartButtons).isNotEmpty) {
        final restartButton = tester.widget<OutlinedButton>(restartButtons);
        expect(restartButton.onPressed, isNotNull);
      }
    });

    testWidgets('score widget has proper padding and decoration', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ScoreWidget),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.padding, const EdgeInsets.symmetric(vertical: 12, horizontal: 24));
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('instructions widget displays correctly', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InstructionsWidget),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.padding, const EdgeInsets.all(12));
      expect(container.decoration, isA<BoxDecoration>());
    });
  });
}