import 'package:state_beacon/state_beacon.dart';

enum Player {
  x(),
  o();

  Player get opponent => this == o ? x : o;
}

enum GameStatus {
  playing(),
  xWins(),
  oWins(),
  draw();

  bool isPlaying() => this == playing;
}

typedef PlayerMove = ({Player player, int position});

typedef GameResult = ({GameStatus status, List<int>? winningLine});

final _emptyBoard = List<Player?>.filled(9, null);

sealed class Action {}

class ResetAction extends Action {}

class MoveAction extends Action {
  final Player player;
  final int position;

  MoveAction({required this.player, required this.position});
}

class GameController extends BeaconController {
  GameController() {
    nextAction.setFilter((prev, next) {
      return switch (next) {
        ResetAction() => true,
        MoveAction move => gameResult.value.status.isPlaying() &&
            board.peek()[move.position] == null,
      };
    });

    nextAction.subscribe((action) {
      switch (action) {
        case ResetAction():
          board.value = _emptyBoard.toList();
        case MoveAction move:
          board[move.position] = move.player;
      }
    }, startNow: false);
  }

  late final board = B.list(_emptyBoard.toList());

  late final gameResult = B.derived(() => _checkWinner(board.value));

  late final nextAction = B.filtered<Action>(ResetAction());

  late final nextPlayer = B.derived(() {
    return switch (nextAction.value) {
      ResetAction() => Player.x,
      MoveAction move => move.player.opponent,
    };
  });

  void doMove(int index) {
    nextAction.value = MoveAction(player: nextPlayer.peek(), position: index);
  }

  void reset() => nextAction.value = ResetAction();

  GameResult _checkWinner(List<Player?> board) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      final b = board[pattern[1]];
      final c = board[pattern[2]];

      if (a != null && a == b && b == c) {
        return (
          status: a == Player.x ? GameStatus.xWins : GameStatus.oWins,
          winningLine: pattern
        );
      }
    }

    if (board.every((cell) => cell != null)) {
      return (status: GameStatus.draw, winningLine: null);
    }

    return (status: GameStatus.playing, winningLine: null);
  }
}
