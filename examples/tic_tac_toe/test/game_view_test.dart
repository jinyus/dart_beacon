import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';
import 'package:tic_tac_toe/src/game/models.dart';
import 'package:tic_tac_toe/src/game/view.dart';

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

      expect(find.text('Tic Tac Toe'), findsOneWidget);
      expect(find.byType(GameStatusWidget), findsOneWidget);
      expect(find.byType(GameBoard), findsOneWidget);
      expect(find.byType(ResetButton), findsOneWidget);
    });

    testWidgets('initial state shows Player X turn', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      expect(find.text("Player X's turn"), findsOneWidget);
    });

    testWidgets('board has 9 cells', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      expect(find.byType(GameCell), findsNWidgets(9));
    });

    testWidgets('tapping cell makes X move', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).first);
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text("Player O's turn"), findsOneWidget);
    });

    testWidgets('tapping second cell makes O move', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();

      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
      expect(find.text("Player X's turn"), findsOneWidget);
    });

    testWidgets('cannot tap occupied cell', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).first);
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text("Player O's turn"), findsOneWidget);

      await tester.tap(find.byType(GameCell).first);
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsNothing);
      expect(find.text("Player O's turn"), findsOneWidget);
    });

    testWidgets('X wins with top row shows win message', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(3));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(4));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(2));
      await tester.pump();

      expect(find.text('Player X Wins!'), findsOneWidget);
    });

    testWidgets('O wins with middle column shows win message', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(2));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(4));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(3));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(7));
      await tester.pump();

      expect(find.text('Player O Wins!'), findsOneWidget);
    });

    testWidgets('draw shows draw message', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(2));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(4));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(3));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(5));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(7));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(6));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(8));
      await tester.pump();

      expect(find.text("It's a Draw!"), findsOneWidget);
    });

    testWidgets('cannot make move after X wins', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(3));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(4));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(2));
      await tester.pump();

      expect(find.text('Player X Wins!'), findsOneWidget);

      await tester.tap(find.byType(GameCell).at(5));
      await tester.pump();

      expect(find.text('X'), findsNWidgets(3));
      expect(find.text('O'), findsNWidgets(2));
    });

    testWidgets('reset button clears the board', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      controller.reset();
      await tester.pumpAndSettle();

      expect(find.text("Player X's turn"), findsOneWidget);
    });

    testWidgets('reset button resets game after X wins', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(3));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(4));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(2));
      await tester.pump();

      expect(find.text('Player X Wins!'), findsOneWidget);

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      controller.reset();
      await tester.pumpAndSettle();

      expect(find.text("Player X's turn"), findsOneWidget);
    });

    testWidgets('can play new game after reset', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);
      controller.reset();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GameCell).at(4));
      await tester.pumpAndSettle();

      expect(find.text('X'), findsOneWidget);
      expect(find.text("Player O's turn"), findsOneWidget);
    });

    testWidgets('reset button has correct icon and text', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      expect(find.widgetWithIcon(ResetButton, Icons.refresh), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);
    });

    testWidgets('complete game flow: X wins with diagonal', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      expect(find.text("Player O's turn"), findsOneWidget);

      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      expect(find.text("Player X's turn"), findsOneWidget);

      await tester.tap(find.byType(GameCell).at(4));
      await tester.pump();
      expect(find.text("Player O's turn"), findsOneWidget);

      await tester.tap(find.byType(GameCell).at(2));
      await tester.pump();
      expect(find.text("Player X's turn"), findsOneWidget);

      await tester.tap(find.byType(GameCell).at(8));
      await tester.pump();
      expect(find.text('Player X Wins!'), findsOneWidget);

      expect(find.text('X'), findsNWidgets(3));
      expect(find.text('O'), findsNWidgets(2));
    });

    testWidgets('complete game flow: O wins with bottom row', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).at(0));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(6));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(1));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(7));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(3));
      await tester.pump();
      await tester.tap(find.byType(GameCell).at(8));
      await tester.pump();

      expect(find.text('Player O Wins!'), findsOneWidget);
      expect(find.text('X'), findsNWidgets(3));
      expect(find.text('O'), findsNWidgets(3));
    });

    testWidgets('complete game flow: full draw scenario', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      final moves = [0, 1, 2, 4, 3, 5, 7, 6, 8];
      for (final move in moves) {
        await tester.tap(find.byType(GameCell).at(move));
        await tester.pump();
      }

      expect(find.text("It's a Draw!"), findsOneWidget);
      expect(find.text('X'), findsNWidgets(5));
      expect(find.text('O'), findsNWidgets(4));
    });

    testWidgets('cells show AnimatedSwitcher for smooth transitions',
        (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      await tester.tap(find.byType(GameCell).first);
      await tester.pump();

      final animatedSwitcher = tester.widget<AnimatedSwitcher>(
        find
            .descendant(
              of: find.byType(GameCell).first,
              matching: find.byType(AnimatedSwitcher),
            )
            .first,
      );

      expect(animatedSwitcher.duration, const Duration(milliseconds: 200));
    });

    testWidgets('game board maintains proper constraints', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(GameBoard),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, isNotNull);
      expect(sizedBox.height, isNotNull);
      expect(sizedBox.width, equals(sizedBox.height));
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

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      expect(controller.board.value, everyElement(null));
      expect(find.text("Player X's turn"), findsOneWidget);

      controller.doMove(0);
      await tester.pump();

      expect(controller.board.value[0], Player.x);
      expect(find.text('X'), findsOneWidget);
      expect(find.text("Player O's turn"), findsOneWidget);

      controller.doMove(1);
      await tester.pump();

      expect(controller.board.value[1], Player.o);
      expect(find.text('O'), findsOneWidget);
      expect(find.text("Player X's turn"), findsOneWidget);
    });

    testWidgets('controller reset reflects in UI', (tester) async {
      await tester.pumpWidget(
        const LiteRefScope(
          child: MaterialApp(
            home: GameView(),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(GameView));
      final controller = gameControllerRef(context);

      controller.doMove(0);
      controller.doMove(1);
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);

      controller.reset();
      await tester.pumpAndSettle();

      expect(find.text('X'), findsNothing);
      expect(find.text('O'), findsNothing);
      expect(controller.board.value, everyElement(null));
    });
  });
}
