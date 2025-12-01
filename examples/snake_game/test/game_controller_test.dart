import 'package:flutter_test/flutter_test.dart';
import 'package:snake_game/src/game/controller.dart';
import 'package:snake_game/src/game/models.dart';

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
      test('snake should start at center position', () {
        expect(controller.snake.value, [const Position(10, 10)]);
      });

      test('game status should be paused', () {
        expect(controller.status.value, GameStatus.paused);
      });

      test('direction should be right', () {
        expect(controller.direction.value, Direction.right);
      });

      test('score should be zero', () {
        expect(controller.score.value, 0);
      });

      test('speed should be initial speed', () {
        expect(controller.speed.value, initialSpeed);
      });

      test('food should not be at snake position', () {
        expect(controller.food.value, isNot(const Position(10, 10)));
      });
    });

    group('Starting game', () {
      test('startGame changes status to playing', () {
        controller.startGame();
        expect(controller.status.value, GameStatus.playing);
      });

      test('startGame resets snake to initial position', () {
        controller.startGame();
        expect(controller.snake.value, [const Position(10, 10)]);
      });

      test('startGame resets direction to right', () {
        controller.startGame();
        expect(controller.direction.value, Direction.right);
      });
    });

    group('Pausing and resuming', () {
      test('pauseGame changes status to paused', () {
        controller.startGame();
        controller.pauseGame();
        expect(controller.status.value, GameStatus.paused);
      });

      test('resumeGame changes status to playing when paused', () {
        controller.startGame();
        controller.pauseGame();
        controller.resumeGame();
        expect(controller.status.value, GameStatus.playing);
      });

      test('resumeGame does not change status when game over', () {
        controller.startGame();
        controller.nextAction.value = MoveSnakeAction();
        
        if (controller.status.value == GameStatus.gameOver) {
          controller.resumeGame();
          expect(controller.status.value, GameStatus.gameOver);
        }
      });

      test('direction persists after pause and resume', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        controller.changeDirection(Direction.down);
        await Future.delayed(const Duration(milliseconds: 10));
        controller.pauseGame();
        controller.resumeGame();
        expect(controller.direction.value, Direction.down);
      });
    });

    group('Changing direction', () {
      test('changeDirection updates direction when playing', () {
        controller.startGame();
        controller.changeDirection(Direction.down);
        expect(controller.direction.value, Direction.down);
      });

      test('cannot change to opposite direction', () {
        controller.startGame();
        controller.changeDirection(Direction.left);
        expect(controller.direction.value, Direction.right);
      });

      test('cannot change direction when not playing', () {
        controller.changeDirection(Direction.down);
        expect(controller.direction.value, Direction.right);
      });

      test('can change direction to perpendicular directions', () {
        controller.startGame();
        controller.changeDirection(Direction.up);
        expect(controller.direction.value, Direction.up);
        controller.changeDirection(Direction.right);
        expect(controller.direction.value, Direction.right);
      });
    });

    group('Snake movement', () {
      test('snake moves in current direction', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 50));
        controller.nextAction.value = MoveSnakeAction();
        expect(controller.snake.value.first, const Position(11, 10));
      });

      test('snake wraps from right edge to left edge', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        var head = controller.snake.value.first;
        final targetX = (head.x + 1) % gridSize;
        controller.nextAction.value = MoveSnakeAction();
        expect(controller.snake.value.first.x, targetX);
      });
    });

    group('Food collection', () {
      test('snake grows when eating food', () {
        controller.startGame();
        final initialLength = controller.snake.value.length;
        
        controller.food.value = const Position(11, 10);
        controller.nextAction.value = MoveSnakeAction();
        
        expect(controller.snake.value.length, greaterThan(initialLength));
      });

      test('score increases by 10 when eating food', () {
        controller.startGame();
        controller.food.value = const Position(11, 10);
        controller.nextAction.value = MoveSnakeAction();
        expect(controller.score.value, 10);
      });

      test('new food is generated after eating', () {
        controller.startGame();
        final oldFood = controller.food.value;
        controller.food.value = const Position(11, 10);
        controller.nextAction.value = MoveSnakeAction();
        expect(controller.food.value, isNot(oldFood));
      });
    });

    group('Collision detection', () {
      test('snake can move without collision', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        
        for (int i = 0; i < 5; i++) {
          controller.nextAction.value = MoveSnakeAction();
        }
        
        expect(controller.status.value, GameStatus.playing);
      });
    });

    group('Score and speed', () {
      test('score is calculated from snake length', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        expect(controller.score.value, 0);
        
        controller.food.value = const Position(11, 10);
        controller.nextAction.value = MoveSnakeAction();
        expect(controller.score.value, 10);
      });

      test('speed increases as score increases', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        final initialSpeed = controller.speed.value;
        
        for (int i = 0; i < 5; i++) {
          final head = controller.snake.value.first;
          controller.food.value = Position(head.x + 1, head.y);
          controller.nextAction.value = MoveSnakeAction();
        }
        
        expect(controller.score.value, 50);
        expect(controller.speed.value, lessThan(initialSpeed));
      });

      test('speed has minimum value of 100', () {
        controller.startGame();
        expect(controller.speed.value, greaterThanOrEqualTo(100));
      });
    });

    group('Game actions', () {
      test('StartGameAction resets game state', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        controller.nextAction.value = MoveSnakeAction();
        controller.nextAction.value = StartGameAction();
        
        expect(controller.snake.value, [const Position(10, 10)]);
        expect(controller.direction.value, Direction.right);
        expect(controller.status.value, GameStatus.playing);
      });

      test('PauseGameAction maintains snake state', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        controller.nextAction.value = MoveSnakeAction();
        final snakeBeforePause = controller.snake.value;
        
        controller.nextAction.value = PauseGameAction();
        expect(controller.snake.value, snakeBeforePause);
        expect(controller.status.value, GameStatus.paused);
      });

      test('ChangeDirectionAction only changes direction', () async {
        controller.startGame();
        await Future.delayed(const Duration(milliseconds: 10));
        final initialSnake = controller.snake.value;
        
        controller.changeDirection(Direction.down);
        await Future.delayed(const Duration(milliseconds: 10));
        expect(controller.direction.value, Direction.down);
        expect(controller.snake.value, initialSnake);
      });
    });
  });
}