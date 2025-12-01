import 'dart:async';
import 'dart:math';

import 'package:state_beacon/state_beacon.dart';

import 'models.dart';

const int gridSize = 20;
const int initialSpeed = 300;

class GameController extends BeaconController {
  GameController() {
    status.subscribe((value) {
      if (!value.isPlaying) {
        _gameTimer?.cancel();
      }
    });

    nextAction.subscribe((action) {
      if (action is StartGameAction || action is ResumeGameAction) {
        _startGameLoop();
      }
    });
  }

  late final ReadableBeacon<List<Position>> snake = B.derived(() {
    final action = nextAction.value;
    final snakeDirection = direction.value;

    if (snake.isEmpty) return [const Position(10, 10)];

    switch (action) {
      case StartGameAction():
        return [const Position(10, 10)];
      case PauseGameAction():
      case ResumeGameAction():
      case ChangeDirectionAction():
        return snake.peek();
      case MoveSnakeAction():
        final currentSnake = snake.peek().toList();
        final head = currentSnake.first;
        var newHead = head.move(snakeDirection);

        if (newHead.x < 0) newHead = Position(gridSize - 1, newHead.y);
        if (newHead.x >= gridSize) newHead = Position(0, newHead.y);
        if (newHead.y < 0) newHead = Position(newHead.x, gridSize - 1);
        if (newHead.y >= gridSize) newHead = Position(newHead.x, 0);

        currentSnake.insert(0, newHead);

        if (newHead != food.peek()) {
          currentSnake.removeLast();
        }

        return currentSnake;
    }
  });

  late final nextAction = B.filtered<GameAction>(
    PauseGameAction(),
    filter: (prev, next) {
      return switch (next) {
        ResumeGameAction() => status.peek() == GameStatus.paused,
        ChangeDirectionAction action =>
          status.peek().isPlaying &&
              action.direction != direction.peek().opposite,
        PauseGameAction() || MoveSnakeAction() => status.peek().isPlaying,
        StartGameAction() => true,
      };
    },
  );

  late final ReadableBeacon<Direction> direction = B.derived(() {
    return switch (nextAction.value) {
      _ when direction.isEmpty => Direction.right,
      StartGameAction() => Direction.right,
      PauseGameAction() when direction.isEmpty => Direction.right,
      ChangeDirectionAction action => action.direction,
      PauseGameAction() => direction.peek(),
      ResumeGameAction() => direction.peek(),
      MoveSnakeAction() => direction.peek(),
    };
  });

  late final ReadableBeacon<GameStatus> status = B.derived(() {
    final action = nextAction.value;
    final currentSnake = snake.value;

    switch (action) {
      case StartGameAction():
        return GameStatus.playing;
      case PauseGameAction():
        return GameStatus.paused;
      case ResumeGameAction():
        return GameStatus.playing;
      case ChangeDirectionAction():
        return status.peek();
      case MoveSnakeAction():
        if (currentSnake.isEmpty) return status.peek();

        final head = currentSnake.first;
        final newHead = head.move(direction.peek());

        // collision
        if (currentSnake.contains(newHead)) {
          return GameStatus.gameOver;
        }
        return status.peek();
    }
  });

  late final ReadableBeacon<int> speed = B.derived(() {
    final currentScore = score.value;
    final reduction = (currentScore ~/ 50) * 30;
    final newSpeed = initialSpeed - reduction;
    return newSpeed > 100 ? newSpeed : 100;
  });

  late final score = B.derived(() {
    return (snake.value.length - 1) * 10;
  });

  late final WritableBeacon<Position> food = B.writable(
    _generateFood(isFirst: true),
  );

  Timer? _gameTimer;

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: speed.peek()),
      (_) => _moveSnake(),
    );
  }

  void _moveSnake() {
    if (status.peek() != GameStatus.playing) return;

    nextAction.value = MoveSnakeAction();

    final currentSnake = snake.peek();
    final newHead = currentSnake.first;

    if (newHead == food.value) {
      if (score.peek() % 50 == 0 && score.peek() > 0) {
        _startGameLoop();
      }
      food.value = _generateFood();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    nextAction.value = StartGameAction();
  }

  void pauseGame() {
    nextAction.value = PauseGameAction();
  }

  void resumeGame() {
    nextAction.value = ResumeGameAction();
  }

  void changeDirection(Direction newDirection) {
    nextAction.value = ChangeDirectionAction(newDirection);
  }

  final _random = Random();
  Position _generateFood({bool isFirst = false}) {
    Position newFood;
    final currentSnake = isFirst ? [const Position(10, 10)] : snake.peek();
    do {
      newFood = Position(_random.nextInt(gridSize), _random.nextInt(gridSize));
    } while (currentSnake.contains(newFood));
    return newFood;
  }
}
