import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/src/game/controller.dart';
import 'package:tic_tac_toe/src/game/models.dart';

void main() {
  late GameController controller;

  setUp(() {
    controller = GameController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('GameController', () {
    group('Initial state', () {
      test('board should be empty', () {
        expect(controller.board.value, everyElement(null));
      });

      test('game status should be playing', () {
        expect(controller.gameResult.value.status, GameStatus.playing);
      });

      test('next player should be X', () {
        expect(controller.nextPlayer.value, Player.x);
      });

      test('winning line should be null', () {
        expect(controller.gameResult.value.winningLine, null);
      });
    });

    group('Making moves', () {
      test('first move should be X', () {
        controller.doMove(0);
        expect(controller.board.value[0], Player.x);
      });

      test('second move should be O', () {
        controller.doMove(0);
        controller.doMove(1);
        expect(controller.board.value[0], Player.x);
        expect(controller.board.value[1], Player.o);
      });

      test('moves should alternate between players', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);
        controller.doMove(3);
        controller.doMove(4);

        expect(controller.board.value[0], Player.x);
        expect(controller.board.value[1], Player.o);
        expect(controller.board.value[2], Player.x);
        expect(controller.board.value[3], Player.o);
        expect(controller.board.value[4], Player.x);
      });

      test('cannot make move on occupied cell', () {
        controller.doMove(0);
        controller.doMove(0);

        expect(controller.board.value[0], Player.x);
        expect(controller.nextPlayer.value, Player.o);
      });

      test('cannot make move after game is won', () {
        controller.doMove(0);
        controller.doMove(3);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(2);

        expect(controller.gameResult.value.status, GameStatus.xWins);

        controller.doMove(5);
        expect(controller.board.value[5], null);
      });

      test('cannot make move after game is draw', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);
        controller.doMove(4);
        controller.doMove(3);
        controller.doMove(5);
        controller.doMove(7);
        controller.doMove(6);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.draw);

        final boardCopy = controller.board.value.toList();
        controller.doMove(0);
        expect(controller.board.value, boardCopy);
      });
    });

    group('Winning conditions - X wins', () {
      test('X wins with top row', () {
        controller.doMove(0);
        controller.doMove(3);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(2);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [0, 1, 2]);
      });

      test('X wins with middle row', () {
        controller.doMove(3);
        controller.doMove(0);
        controller.doMove(4);
        controller.doMove(1);
        controller.doMove(5);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [3, 4, 5]);
      });

      test('X wins with bottom row', () {
        controller.doMove(6);
        controller.doMove(0);
        controller.doMove(7);
        controller.doMove(1);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [6, 7, 8]);
      });

      test('X wins with left column', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(3);
        controller.doMove(2);
        controller.doMove(6);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [0, 3, 6]);
      });

      test('X wins with middle column', () {
        controller.doMove(1);
        controller.doMove(0);
        controller.doMove(4);
        controller.doMove(2);
        controller.doMove(7);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [1, 4, 7]);
      });

      test('X wins with right column', () {
        controller.doMove(2);
        controller.doMove(0);
        controller.doMove(5);
        controller.doMove(1);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [2, 5, 8]);
      });

      test('X wins with top-left to bottom-right diagonal', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(2);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [0, 4, 8]);
      });

      test('X wins with top-right to bottom-left diagonal', () {
        controller.doMove(2);
        controller.doMove(0);
        controller.doMove(4);
        controller.doMove(1);
        controller.doMove(6);

        expect(controller.gameResult.value.status, GameStatus.xWins);
        expect(controller.gameResult.value.winningLine, [2, 4, 6]);
      });
    });

    group('Winning conditions - O wins', () {
      test('O wins with top row', () {
        controller.doMove(3);
        controller.doMove(0);
        controller.doMove(4);
        controller.doMove(1);
        controller.doMove(6);
        controller.doMove(2);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [0, 1, 2]);
      });

      test('O wins with middle row', () {
        controller.doMove(0);
        controller.doMove(3);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(6);
        controller.doMove(5);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [3, 4, 5]);
      });

      test('O wins with bottom row', () {
        controller.doMove(0);
        controller.doMove(6);
        controller.doMove(1);
        controller.doMove(7);
        controller.doMove(3);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [6, 7, 8]);
      });

      test('O wins with left column', () {
        controller.doMove(1);
        controller.doMove(0);
        controller.doMove(2);
        controller.doMove(3);
        controller.doMove(5);
        controller.doMove(6);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [0, 3, 6]);
      });

      test('O wins with middle column', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);
        controller.doMove(4);
        controller.doMove(3);
        controller.doMove(7);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [1, 4, 7]);
      });

      test('O wins with right column', () {
        controller.doMove(0);
        controller.doMove(2);
        controller.doMove(1);
        controller.doMove(5);
        controller.doMove(3);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [2, 5, 8]);
      });

      test('O wins with top-left to bottom-right diagonal', () {
        controller.doMove(1);
        controller.doMove(0);
        controller.doMove(2);
        controller.doMove(4);
        controller.doMove(3);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [0, 4, 8]);
      });

      test('O wins with top-right to bottom-left diagonal', () {
        controller.doMove(0);
        controller.doMove(2);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(3);
        controller.doMove(6);

        expect(controller.gameResult.value.status, GameStatus.oWins);
        expect(controller.gameResult.value.winningLine, [2, 4, 6]);
      });
    });

    group('Draw condition', () {
      test('game ends in draw when board is full with no winner', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);
        controller.doMove(4);
        controller.doMove(3);
        controller.doMove(5);
        controller.doMove(7);
        controller.doMove(6);
        controller.doMove(8);

        expect(controller.gameResult.value.status, GameStatus.draw);
        expect(controller.gameResult.value.winningLine, null);
        expect(controller.board.value, everyElement(isNotNull));
      });
    });

    group('Reset functionality', () {
      test('reset clears the board', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);

        controller.reset();

        expect(controller.board.value, everyElement(null));
      });

      test('reset sets status to playing', () {
        controller.doMove(0);
        controller.doMove(3);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(2);

        expect(controller.gameResult.value.status, GameStatus.xWins);

        controller.reset();

        expect(controller.gameResult.value.status, GameStatus.playing);
      });

      test('reset sets next player to X', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);

        expect(controller.nextPlayer.value, Player.o);

        controller.reset();

        expect(controller.nextPlayer.value, Player.x);
      });

      test('reset clears winning line', () {
        controller.doMove(0);
        controller.doMove(3);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(2);

        expect(controller.gameResult.value.winningLine, [0, 1, 2]);

        controller.reset();

        expect(controller.gameResult.value.winningLine, null);
      });

      test('can play new game after reset', () {
        controller.doMove(0);
        controller.doMove(1);
        controller.doMove(2);

        controller.reset();

        controller.doMove(4);
        expect(controller.board.value[4], Player.x);
        expect(controller.nextPlayer.value, Player.o);
      });
    });

    group('Next player tracking', () {
      test('next player alternates correctly throughout the game', () {
        expect(controller.nextPlayer.value, Player.x);

        controller.doMove(0);
        expect(controller.nextPlayer.value, Player.o);

        controller.doMove(1);
        expect(controller.nextPlayer.value, Player.x);

        controller.doMove(2);
        expect(controller.nextPlayer.value, Player.o);

        controller.doMove(3);
        expect(controller.nextPlayer.value, Player.x);
      });

      test('next player stays same when invalid move is made', () {
        controller.doMove(0);
        expect(controller.nextPlayer.value, Player.o);

        controller.doMove(0);
        expect(controller.nextPlayer.value, Player.o);
      });

      test('next player stays same after game ends', () {
        controller.doMove(0);
        controller.doMove(3);
        controller.doMove(1);
        controller.doMove(4);
        controller.doMove(2);

        expect(controller.gameResult.value.status, GameStatus.xWins);

        final expectedPlayer = controller.nextPlayer.value;
        controller.doMove(5);
        expect(controller.nextPlayer.value, expectedPlayer);
      });
    });
  });
}
