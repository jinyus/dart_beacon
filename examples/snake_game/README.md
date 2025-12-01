# Snake Game

Classic Snake game built with Flutter and state_beacon for state management.



https://github.com/user-attachments/assets/2b1352ae-1d9b-4ee9-84b4-3e843b54c527



## Project Structure

```
lib/
├── main.dart              # App entry point with LiteRefScope
├── src/
│   ├── app.dart          # MaterialApp configuration
│   └── game/
│       ├── controller.dart # Game logic with beacons
│       ├── models.dart     # Data models (Direction, Position, GameAction)
│       └── view.dart       # UI rendering
```

## How Beacons Are Used

This example demonstrates reactive state management using several beacon types:

### 1. Filtered Beacon (`nextAction`)
```dart
late final nextAction = B.filtered<GameAction>(
  PauseGameAction(),
  filter: (_, next) => // validation logic
);
```
- Validates and filters incoming game actions
- Prevents invalid moves (e.g., snake reversing direction)
- Ensures actions only apply when game state allows them

### 2. Derived Beacons (Computed State)

**Snake Position (`snake`)**
```dart
late final ReadableBeacon<List<Position>> snake = B.derived(() {
  final action = nextAction.value;
  final snakeDirection = direction.value;
  // Calculate new snake position based on action
});
```
- Reactively updates when `nextAction` or `direction` changes
- Handles movement, wrapping at edges, and growth when eating food

**Direction (`direction`)**
- Derives current direction from action stream
- Prevents opposite direction changes

**Game Status (`status`)**
- Automatically detects game over (collision)
- Manages playing/paused/game over states

**Speed (`speed`)**
- Dynamically calculates based on score
- Decreases by 30ms per 50 points (min: 100ms)

**Score (`score`)**
- Derived from snake length: `(length - 1) * 10`

### 3. Writable Beacon (`food`)
```dart
late final WritableBeacon<Position> food = B.writable(_generateFood());
```
- Holds food position that can be directly updated
- Regenerated when snake eats it

### 4. Beacon Subscriptions
```dart
status.subscribe((nextStatus) {
  if (nextStatus.isPlaying) _startGameLoop();
  else _gameTimer?.cancel();
});
```
- Automatically starts/stops game loop based on status changes
- Restarts game loop when speed changes

### State Flow

1. User input → `changeDirection()` / `startGame()` / `pauseGame()`
2. Updates `nextAction` filtered beacon
3. Derived beacons automatically recalculate (`snake`, `direction`, `status`, etc.)
4. UI rebuilds reactively via `watch()` (in view.dart)
5. Side effects trigger via subscriptions (game loop, timers)

This architecture demonstrates:
- Declarative state management
- Automatic dependency tracking
- Efficient updates (only affected beacons recompute)
- Clear separation of state logic and UI
