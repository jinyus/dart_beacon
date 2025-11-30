import 'package:state_beacon/state_beacon.dart';

enum Player { x, o }

enum GameStatus { playing, xWins, oWins, draw }

class GameState {
  final List<Player?> board;
  final Player currentPlayer;
  final GameStatus status;
  final List<int>? winningLine;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.status,
    this.winningLine,
  });

  GameState copyWith({
    List<Player?>? board,
    Player? currentPlayer,
    GameStatus? status,
    List<int>? winningLine,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      winningLine: winningLine ?? this.winningLine,
    );
  }
}

class GameController extends BeaconController {
  late final gameState = B.writable(
    GameState(
      board: List.filled(9, null),
      currentPlayer: Player.x,
      status: GameStatus.playing,
    ),
  );

  void makeMove(int index) {
    final state = gameState.value;

    if (state.status != GameStatus.playing || state.board[index] != null) {
      return;
    }

    final newBoard = List<Player?>.from(state.board);
    newBoard[index] = state.currentPlayer;

    final winCheck = _checkWinner(newBoard);
    final status = winCheck.status;
    final winningLine = winCheck.winningLine;

    gameState.value = state.copyWith(
      board: newBoard,
      currentPlayer:
          state.currentPlayer == Player.x ? Player.o : Player.x,
      status: status,
      winningLine: winningLine,
    );
  }

  void reset() {
    gameState.value = GameState(
      board: List.filled(9, null),
      currentPlayer: Player.x,
      status: GameStatus.playing,
    );
  }

  ({GameStatus status, List<int>? winningLine}) _checkWinner(
      List<Player?> board) {
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
