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
  }

  late final snake = B.writable<List<Position>>([const Position(10, 10)]);
  // late final direction = B.writable<Direction>(Direction.right);
  late final score = B.writable<int>(0);

  late final nextAction = B.filtered<GameAction>(
    PauseGameAction(),
    filter: (prev, next) => true,
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

        if (_isCollision(newHead, currentSnake)) {
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

  late final ReadableBeacon<Position> food = B.derived(() {
    // game just started
    if (snake.value.length == 1 && food.isEmpty) return _generateFood();

    // snake eat food
    if (snake.value.first == food.peek()) return _generateFood();

    // snake moves
    return food.peek();
  });

  Timer? _gameTimer;

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    snake.value = [const Position(10, 10)];
    score.value = 0;
    nextAction.value = StartGameAction();
    _startGameLoop();
  }

  void pauseGame() {
    nextAction.value = PauseGameAction();
  }

  void resumeGame() {
    if (status.peek() == GameStatus.paused) {
      nextAction.value = ResumeGameAction();
      _startGameLoop();
    }
  }

  void changeDirection(Direction newDirection) {
    if (!status.peek().isPlaying) return;
    if (newDirection != direction.peek().opposite) {
      nextAction.value = ChangeDirectionAction(newDirection);
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: speed.peek()),
      (_) => _moveSnake(),
    );
  }

  void _moveSnake() {
    if (status.peek() != GameStatus.playing) return;

    final currentSnake = snake.peek().toList();
    final head = currentSnake.first;
    var newHead = head.move(direction.peek());

    // Wrap around walls
    if (newHead.x < 0) newHead = Position(gridSize - 1, newHead.y);
    if (newHead.x >= gridSize) newHead = Position(0, newHead.y);
    if (newHead.y < 0) newHead = Position(newHead.x, gridSize - 1);
    if (newHead.y >= gridSize) newHead = Position(newHead.x, 0);

    nextAction.value = MoveSnakeAction();

    currentSnake.insert(0, newHead);

    if (newHead == food.peek()) {
      score.value = score.peek() + 10;

      if (score.peek() % 50 == 0) {
        _startGameLoop();
      }
    } else {
      currentSnake.removeLast();
    }

    snake.value = currentSnake;
  }

  bool _isCollision(Position head, List<Position> snakeBody) {
    return snakeBody.contains(head);
  }

  Position _generateFood() {
    final random = Random();
    Position newFood;
    do {
      newFood = Position(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.peek().contains(newFood));
    return newFood;
  }
}
