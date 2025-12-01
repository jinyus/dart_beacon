# Tic Tac Toe

Classic Tic Tac Toe game built with Flutter and state_beacon for state management.



https://github.com/user-attachments/assets/b1f0c00e-20d8-4fbc-9f32-8185736c1a75


## Project Structure

```
lib/
├── main.dart              # App entry point with LiteRefScope
├── src/
│   ├── app.dart          # MaterialApp configuration
│   └── game/
│       ├── controller.dart # Game logic with beacons
│       ├── models.dart     # Data models (Player, GameStatus, Action)
│       └── view.dart       # UI rendering
```

## How Beacons Are Used

This example demonstrates a simple yet powerful reactive game implementation using beacons:

### 1. Filtered Beacon (`nextAction`)
```dart
late final nextAction = B.filtered<Action>(ResetAction(), filter: (_, next) {
  return switch (next) {
    ResetAction() => true,
    MoveAction move => gameResult.value.status.isPlaying() &&
        board.peek()[move.position] == null,
  };
});
```
- Validates moves before accepting them
- Prevents playing on occupied cells
- Blocks moves when game is over
- Central action stream that drives all state changes

### 2. Derived Beacons (Computed State)

**Board State (`board`)**
```dart
late final ReadableBeacon<List<Player?>> board = B.derived(() {
  final action = nextAction.value;
  switch (action) {
    case ResetAction():
      return _emptyBoard.toList();
    case MoveAction move:
      final current = board.peek().toList();
      current[move.position] = move.player;
      return current;
  }
});
```
- Reactively updates based on validated actions
- Manages the 9-cell game board
- Resets to empty state on reset action

**Game Result (`gameResult`)**
```dart
late final gameResult = B.derived(() => _checkWinner(board.value));
```
- Automatically checks for win/draw conditions whenever board changes
- Returns winning line positions for UI highlighting
- Determines game status (playing, xWins, oWins, draw)

**Next Player (`nextPlayer`)**
```dart
late final nextPlayer = B.derived(() {
  return switch (nextAction.value) {
    ResetAction() => Player.x,
    MoveAction move => move.player.opponent,
  };
});
```
- Alternates between X and O
- Resets to X when game restarts

### State Flow

1. User taps cell → `doMove(index)` called
2. Creates `MoveAction` with current player and position
3. `nextAction` filters/validates the move
4. If valid, `board` beacon recalculates new board state
5. `gameResult` automatically checks for winner
6. `nextPlayer` switches to opponent
7. UI rebuilds via `watch()` (in view.dart)

### Key Patterns Demonstrated

- **Single source of truth**: All state flows through `nextAction`
- **Declarative validation**: Filter logic prevents invalid states
- **Automatic derivation**: Game result calculated on every board change
- **Peek optimization**: Using `.peek()` to read values without creating dependencies
- **Immutable updates**: Creating new lists instead of mutating existing state

This architecture ensures the game logic is simple, testable, and impossible to get into an invalid state.
