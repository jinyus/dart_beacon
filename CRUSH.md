# CRUSH.md - Dart Beacon Development Guide

## Project Overview

**dart_beacon** is a reactive state management library for Dart and Flutter. It implements a beacon/signal-based reactive system using node coloring for fine-grained reactivity. The project consists of multiple packages and examples.

**Repository**: https://github.com/zupat/dart_beacon

## Project Structure

```
dart_beacon/
├── packages/
│   ├── state_beacon_core/          # Core reactive library (Dart-only)
│   ├── state_beacon/               # Main library (re-exports core + Flutter utilities)
│   ├── state_beacon_flutter/       # Flutter-specific utilities
│   └── state_beacon_lints/         # Custom lint rules for beacons
├── examples/
│   ├── flutter_main/               # Main Flutter demo app
│   ├── shopping_cart/              # E-commerce example
│   ├── counter/                    # Simple counter example
│   ├── vgv_best_practices/         # VGV best practices demo
│   ├── skeleton/                   # Flutter template/skeleton
│   ├── auth_flow/                  # Authentication flow example
│   ├── github_search/              # GitHub search example
└── assets/                         # Demo images and banners
```

## Key Technologies

- **Language**: Dart 3.0+
- **Platforms**: Dart VM, Flutter (iOS, Android, Web, Desktop)
- **State Management**: Signal-based (fine-grained reactivity using node coloring)
- **Testing**: Built-in `test` package
- **Linting**: Very Good Analysis + custom lint package

## Essential Commands

### Setup & Dependencies

```bash
# Install all dependencies for all packages and examples
./run.sh deps

# From within a specific package
cd packages/state_beacon_core && flutter pub get
```

### Testing

```bash
# Test specific package
./run.sh test core          # Test state_beacon_core
./run.sh test flutter       # Test state_beacon_flutter
./run.sh test main          # Test state_beacon (main package)
./run.sh test example        # Test all examples (flutter_main, shopping_cart, counter)
./run.sh test all           # Test everything

# Direct testing within a package (with coverage)
cd packages/state_beacon_core && flutter test --coverage --timeout 5s

# Without coverage (faster)
cd packages/state_beacon_core && flutter test
```

### Code Quality

```bash
# Analyze code in a package
flutter analyze

# Both get + analyze + test with coverage
flutter pub get && flutter analyze && flutter test --coverage
```

### Publishing

```bash
# Publish a package to pub.dev (from repository root)
./run.sh pub core           # Publish state_beacon_core
./run.sh pub flutter        # Publish state_beacon_flutter
./run.sh pub main           # Publish state_beacon
./run.sh pub lint           # Publish state_beacon_lints
```

## Code Organization & Patterns

### Library Structure

Each package follows a standard structure:

```
lib/
├── package_name.dart           # Main export file (library declaration)
└── src/
    ├── beacons/                # Core beacon implementations
    │   ├── readable.dart
    │   ├── writable.dart
    │   ├── derived.dart
    │   ├── future.dart
    │   ├── stream.dart
    │   ├── buffered.dart
    │   ├── debounced.dart
    │   ├── throttled.dart
    │   ├── filtered.dart
    │   ├── timestamped.dart
    │   ├── undo_redo.dart
    │   ├── list.dart
    │   ├── map.dart
    │   ├── set.dart
    │   └── ... (other beacon types)
    ├── consumers/               # Consumer implementations (effects, subscriptions)
    ├── extensions/              # Extension methods on beacons
    ├── creator/                 # BeaconGroup and creation utilities
    ├── controller/              # BeaconController base class
    ├── mixins/                  # Shared mixins (beacon_wrapper, autosleep)
    ├── common/                  # Common utilities (AsyncValue, exceptions)
    ├── observer.dart            # Observer pattern for debugging
    ├── producer.dart            # Producer/base beacon class
    ├── consumer.dart            # Consumer base class
    └── scheduler.dart           # Scheduler for effects
```

### Beacon Class Hierarchy

```
ReadableBeacon<T> (immutable, base class)
├── Producer<T>
│   ├── WritableBeacon<T>
│   ├── DerivedBeacon<T>
│   ├── FutureBeacon<T>
│   ├── StreamBeacon<T>
│   ├── RawStreamBeacon<T>
│   ├── BufferedCountBeacon<T>
│   ├── BufferedTimeBeacon<T>
│   ├── DebouncedBeacon<T>
│   ├── ThrottledBeacon<T>
│   ├── FilteredBeacon<T>
│   ├── TimestampBeacon<T>
│   ├── UndoRedoBeacon<T>
│   ├── PeriodicBeacon<T>
│   ├── ListBeacon<T>
│   ├── MapBeacon<T>
│   └── SetBeacon<T>
```

### Naming Conventions

- **Beacon types**: `XBeacon` where X is the type (e.g., `WritableBeacon`, `DerivedBeacon`)
- **Internal classes**: Use `_ClassName` for private/internal classes
- **Time constants**: `const Duration` with `k` prefix, e.g., `k10ms`, `k500ms`
- **Test files**: `*_test.dart` (mirror source structure in `test/` directory)
- **Beacon names**: Optional parameter for debugging, e.g., `Beacon.writable(0, name: 'counter')`

### File Organization in `src/`

- Each beacon type gets its own file in `src/beacons/`
- No file should be too large; extract utilities to `common/` or separate files
- Part files (`part of`) used in `producer.dart` for related beacon implementations
- Extensions are in separate files in `src/extensions/` organized by concern (readable, writable, chain, iterable)

## Naming & Style Patterns

### Code Style

- **Very Good Analysis** lint set (see `analysis_options.yaml`)
- Disabled rules: `avoid_positional_boolean_parameters`, `cascade_invocations`, `flutter_style_todos`
- Use `// ignore_for_file: rule_name` at top of files when specific rules must be disabled
- Use `// coverage:ignore-start` and `// coverage:ignore-end` for untestable code
- Public API documented with doc comments; internal code not required

### Beacon Creation

```dart
// Writable
final counter = Beacon.writable(0);
final lazyCounter = Beacon.lazyWritable<int>();

// Derived
final doubled = Beacon.derived(() => counter.value * 2);

// Future
final data = Beacon.future(() async => await fetchData());

// Stream
final stream = Beacon.stream(() => myStream);

// Specialized
final debounced = Beacon.debounced('', duration: k500ms);
final buffered = Beacon.bufferedCount<int>(10);
final list = Beacon.list<int>([]);
```

### Beacon Methods & Properties

- **Access value**: `.value` or `.call()` (tracked as dependency)
- **Peek value**: `.peek()` (not tracked as dependency)
- **Read without dependency**: In tests, use `.peek()` to avoid registering as dependent
- **Subscribe**: `.subscribe((value) { })` returns unsubscribe function
- **Watch in widgets**: `.watch(context)` rebuilds widget on change
- **Observe**: `.observe(context, (prev, next) { })` for side effects
- **Convert to stream**: `.toStream()`
- **Dispose**: `.dispose()` releases resources
- **Register disposal callback**: `.onDispose(() { })`

## Testing Approach & Patterns

### Test File Structure

- Mirror source structure in `test/` directory
- Import from `package:state_beacon_core/state_beacon_core.dart`
- Import test utilities from `../common.dart`
- Use `test()` for individual test cases

### Common Test Helpers

```dart
// From packages/state_beacon_core/test/common.dart
const k1ms = Duration(milliseconds: 1);
const k10ms = Duration(milliseconds: 10);
Future<void> delay([Duration? duration]) => Future.delayed(duration ?? (k10ms * 1.1));
```

### Testing Patterns

```dart
// Testing basic beacon
test('beacon value updates', () {
  var beacon = Beacon.writable(10);
  beacon.value = 20;
  expect(beacon.value, 20);
});

// Testing derived beacons
test('derived beacon recomputes', () {
  var count = Beacon.writable(5);
  var doubled = Beacon.derived(() => count.value * 2);
  expect(doubled.value, 10);
  count.value = 7;
  expect(doubled.value, 14);
});

// Testing effects (requires scheduler flush)
test('effect runs on change', () {
  var beacon = Beacon.writable(0);
  var called = 0;
  
  Beacon.effect(() {
    beacon.value; // track dependency
    called++;
  });
  
  BeaconScheduler.flush(); // manually flush for sync tests
  expect(called, 1);
  
  beacon.value = 5;
  BeaconScheduler.flush();
  expect(called, 2);
});

// Testing async (futures/streams)
test('future beacon updates', () async {
  var beacon = Beacon.future(() async => 'hello');
  expect(beacon.isLoading, true);
  await Future.delayed(k10ms);
  expect(beacon.isData, true);
  expect(beacon.unwrapValue(), 'hello');
});

// Testing with streams
test('stream beacon emits values', () async {
  var beacon = Beacon.stream(() => Stream.fromIterable([1, 2, 3]));
  await expectLater(beacon.toStream(), emitsInOrder([
    AsyncLoading(),
    AsyncData(1),
    AsyncData(2),
    AsyncData(3),
  ]));
});

// Using buffer() for testing
test('test with buffer', () {
  var beacon = Beacon.writable(10);
  var buff = beacon.buffer(2);
  
  beacon.value = 20;
  expect(buff.value, equals([10, 20]));
});

// Using next() for testing
test('test with next()', () async {
  var beacon = Beacon.writable(10);
  expectLater(beacon.next(), completion(30));
  beacon.value = 30;
});
```

### Widget Testing

- For Flutter widgets, use `flutter test` in the package directory
- Scheduler automatically flushes when `tester.pumpAndSettle()` is called (no manual flush needed)
- Import test helpers: `import 'package:flutter_test/flutter_test.dart';`

### Running Tests

```bash
# With coverage
flutter test --coverage --timeout 5s

# Without coverage (faster)
flutter test

# Specific test file
flutter test test/src/core_test.dart

# With grep pattern
flutter test -k "2 Beacon.writables"
```

## Important Gotchas & Non-Obvious Patterns

### 1. **Dependency Tracking Only Before Async Gap**

When using `Beacon.future()`, only beacons accessed **before the `await`** are tracked as dependencies:

```dart
// DON'T - doubledCounter won't be tracked after await
final futureCounter = Beacon.future(() async {
  final count = counter.value;
  await Future.delayed(Duration(seconds: count));
  final doubled = doubledCounter.value;  // NOT tracked!
  return '$count x 2 = $doubled';
});

// DO - access both futures before await
final futureCounter = Beacon.future(() async {
  final countFuture = counter.toFuture();  // get Future before await
  final doubleFuture = doubledCounter.toFuture();
  final (count, doubled) = await (countFuture, doubleFuture).wait;
  return '$count x 2 = $doubled';
});
```

### 2. **BeaconScheduler.flush() Required for Sync Tests**

Effects are asynchronous and queued. Manual scheduler flush is needed in unit tests:

```dart
var beacon = Beacon.writable(0);
var called = 0;

Beacon.effect(() {
  beacon.value;
  called++;
});

// Without flush: called == 0 (effect hasn't run yet)
BeaconScheduler.flush();
// Now: called == 1
```

Widget tests don't need manual flushing (automatic via `pumpAndSettle()`).

### 3. **ListBeacon Mutation Does Not Update Previous Value**

`ListBeacon` mutates in-place; `previousValue` and current value are always the same:

```dart
var nums = Beacon.list<int>([1, 2, 3]);
Beacon.effect(() {
  print(nums.value); // [1, 2, 3]
});

nums.add(4);
// effect sees: [1, 2, 3, 4] (same reference, previous was mutated)
// If you need old vs new, use Beacon.writable<List>([]) instead
```

### 4. **Lazy Beacons Must Be Set Before Read**

`lazyWritable()` beacons throw if read before first write:

```dart
final beacon = Beacon.lazyWritable<int>();
print(beacon.value); // throws UninitializeLazyReadException()

beacon.value = 10;
print(beacon.value); // OK: 10
```

### 5. **Disposal Propagates Downstream**

When a beacon is disposed, all dependent beacons and effects are automatically disposed:

```dart
final a = Beacon.writable(10);
final derived = Beacon.derived(() => a.value * 2);
Beacon.effect(() => print(derived.value));

a.dispose();
// Both derived and effect are now disposed too
```

### 6. **Chaining Limitations**

- `buffer()` and `bufferTime()` **must be at the end** of a chain
- Writes to chained beacons are re-routed to the original source (except when type changes)

```dart
// GOOD
count.debounce().filter();

// BAD - buffer not at end
count.buffer(10).filter();

// Type change breaks re-routing
final counted = count.map((v) => '$v').filter(...);
// writes to counted do NOT re-route to count (different types)
```

### 7. **shouldSleep Parameter Behavior**

`Beacon.future()` and `Beacon.stream()` with `shouldSleep: true` (default) will:
- Stop executing when no one is watching
- Resume in `loading` state when watched again (re-run callback)

### 8. **Coverage Ignore Patterns**

Use coverage ignore markers for untestable code:

```dart
// coverage:ignore-start
void someUntestableCode() { }
// coverage:ignore-end
```

## File Modification Tips

### Adding a New Beacon Type

1. Create `lib/src/beacons/my_beacon.dart`
2. Extend `Producer<T>` class
3. Implement required methods: `_computeValue()`, `dispose()`, etc.
4. Export in `lib/package_name.dart`
5. Create `test/src/beacons/my_beacon_test.dart`
6. Test patterns: writable, chaining, disposal, edge cases

### Adding Extension Methods

1. Create `lib/src/extensions/my_extension.dart`
2. Define extension on target class (e.g., `extension ReadableBeaconExt on ReadableBeacon<T>`)
3. Export in `lib/src/extensions/extensions.dart`
4. Create `test/src/extensions/my_extension_test.dart`

### Modifying Shared Code

- Use `lsp_references` to find all usages before changing
- Common utilities go in `lib/src/common/`
- Mixins go in `lib/src/mixins/`
- Be careful with changes to `producer.dart` (base class)

## CI/CD & Publishing

### GitHub Actions Workflow

- Runs on: Pull requests to `main`, workflow dispatch
- Executes in: `ubuntu-latest`
- Tests: `state_beacon_core` + `state_beacon` packages with coverage
- Coverage uploaded to Codecov

### Publishing Process

```bash
# 1. Ensure all tests pass
./run.sh test all

# 2. Update version in pubspec.yaml for the package
cd packages/state_beacon_core
# Edit pubspec.yaml version

# 3. Update CHANGELOG.md

# 4. Publish (from package directory)
./run.sh pub core

# or directly
dart pub publish
```

Note: `run.sh pub` automatically:
- Copies root `Readme.md` to package `README.md`
- Creates `.pubignore` to exclude test files
- Runs `dart pub publish`

## Useful References

- **Main Beacon API**: `packages/state_beacon_core/lib/src/producer.dart`
- **Consumer/Effect**: `packages/state_beacon_core/lib/src/consumer.dart`
- **AsyncValue helpers**: `packages/state_beacon_core/lib/src/common/async_value.dart`
- **Extension methods**: All in `lib/src/extensions/` directory
- **Test helpers**: `packages/state_beacon_core/test/common.dart`
- **Example implementations**: `examples/flutter_main/lib`, `examples/shopping_cart/lib`

## Quick Debug Tips

### Enable Beacon Observer Logging

```dart
import 'package:state_beacon_core/state_beacon_core.dart';

void main() {
  BeaconObserver.useLogging(); // or: BeaconObserver.instance = LoggingObserver()
  
  var counter = Beacon.writable(0, name: 'counter');
  var doubled = Beacon.derived(() => counter.value * 2, name: 'doubled');
  
  // Logs all beacon operations
  counter.value = 5;
}
```

### Check Beacon State in Tests

```dart
final beacon = Beacon.future(() async => await fetchData());

expect(beacon.isLoading, true);
expect(beacon.isData, false);
expect(beacon.isError, false);

// Wait for completion
await Future.delayed(k10ms);
expect(beacon.isData, true);
expect(beacon.value.unwrap(), expectedData);
```

### Monitor Subscriptions

```dart
final unsub = beacon.subscribe((value) {
  print('Changed to: $value');
});

// ... later
unsub(); // Unsubscribe
```

## Development Workflow

1. **Make changes** in `packages/*/lib/src/`
2. **Write/update tests** in corresponding `test/src/` location
3. **Run tests locally**: `./run.sh test core` (or relevant package)
4. **Check analysis**: `flutter analyze`
5. **Create PR** with changes
6. **CI runs** automatically on PR
7. **Merge** when green
8. **Publish** when ready (manually with `./run.sh pub <package>`)

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| `BeaconScheduler.flush()` not working | Make sure you're in a sync test context, not widget test |
| Effect not running | Verify beacon value is accessed (not just peek'd), flush scheduler |
| Derived beacon not recomputing | Check that dependency beacon is accessed before async gap |
| Test timeout | Increase timeout: `flutter test --timeout 10s` |
| Coverage gaps | Use `// coverage:ignore-start` for untestable code |
| Beacon disposed error | Check disposal order; disposed beacons can't be updated |
| Widget not rebuilding | Use `.watch(context)` not `.value`; avoid `.peek()` in widgets |
