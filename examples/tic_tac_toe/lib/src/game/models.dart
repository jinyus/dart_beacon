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

sealed class Action {}

class ResetAction extends Action {}

class MoveAction extends Action {
  final Player player;
  final int position;

  MoveAction({required this.player, required this.position});
}
