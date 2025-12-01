enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Direction(this.dx, this.dy);

  final int dx;
  final int dy;

  Direction get opposite => switch (this) {
        Direction.up => Direction.down,
        Direction.down => Direction.up,
        Direction.left => Direction.right,
        Direction.right => Direction.left,
      };
}

enum GameStatus {
  playing,
  gameOver,
  paused;

  bool get isPlaying => this == GameStatus.playing;
}

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position move(Direction direction) {
    return Position(x + direction.dx, y + direction.dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Position && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

sealed class GameAction {}

class StartGameAction extends GameAction {}

class PauseGameAction extends GameAction {}

class ResumeGameAction extends GameAction {}

class ChangeDirectionAction extends GameAction {
  final Direction direction;

  ChangeDirectionAction(this.direction);
}

class MoveSnakeAction extends GameAction {} 