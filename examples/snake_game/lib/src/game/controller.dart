import 'dart:async';
import 'dart:math';

import 'package:state_beacon/state_beacon.dart';

import 'models.dart';

const int gridSize = 20;
const int initialSpeed = 300;

class GameController extends BeaconController {
  late final snake = B.writable<List<Position>>([const Position(10, 10)]);
  late final food = B.writable<Position>(_generateFood());
  late final direction = B.writable<Direction>(Direction.right);
  late final status = B.writable<GameStatus>(GameStatus.paused);
  late final score = B.writable<int>(0);
  late final speed = B.writable<int>(initialSpeed);

  Timer? _gameTimer;

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void startGame() {
    snake.value = [const Position(10, 10)];
    food.value = _generateFood();
    direction.value = Direction.right;
    status.value = GameStatus.playing;
    score.value = 0;
    speed.value = initialSpeed;
    _startGameLoop();
  }

  void pauseGame() {
    status.value = GameStatus.paused;
    _gameTimer?.cancel();
  }

  void resumeGame() {
    if (status.value == GameStatus.paused) {
      status.value = GameStatus.playing;
      _startGameLoop();
    }
  }

  void changeDirection(Direction newDirection) {
    if (!status.value.isPlaying) return;
    if (newDirection != direction.peek().opposite) {
      direction.value = newDirection;
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
    final newHead = head.move(direction.peek());

    if (_isCollision(newHead, currentSnake)) {
      status.value = GameStatus.gameOver;
      _gameTimer?.cancel();
      return;
    }

    currentSnake.insert(0, newHead);

    if (newHead == food.peek()) {
      score.value = score.peek() + 10;
      food.value = _generateFood();
      
      if (score.peek() % 50 == 0 && speed.peek() > 100) {
        final newSpeed = speed.peek() - 30;
        speed.value = newSpeed;
        _startGameLoop();
      }
    } else {
      currentSnake.removeLast();
    }

    snake.value = currentSnake;
  }

  bool _isCollision(Position head, List<Position> snakeBody) {
    if (head.x < 0 || head.x >= gridSize || head.y < 0 || head.y >= gridSize) {
      return true;
    }

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
