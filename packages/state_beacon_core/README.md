<p align="center">
  <img width="650" src="https://github.com/jinyus/dart_beacon/blob/main/assets/state_beacon_banner.jpeg?raw=true">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-purple"> 
  <a href="https://app.codecov.io/github/jinyus/dart_beacon"><img src="https://img.shields.io/codecov/c/github/jinyus/dart_beacon"></a>
  <a href="https://pub.dev/packages/state_beacon"><img src="https://img.shields.io/pub/points/state_beacon?color=blue"></a>
   <img alt="stars" src="https://img.shields.io/github/stars/jinyus/dart_beacon?style=social"/>
</p>

## Overview

A Beacon is a reactive primitive(`signal`) and simple state management solution for Dart and Flutter; `state_beacon` leverages the [node coloring technique](https://milomg.dev/2022-12-01/reactivity) created by [Milo Mighdoll](https://x.com/milomg__) and used in the latest versions of [SolidJS](https://www.youtube.com/watch?v=jHDzGYHY2ew&t=5291s) and [reactively](https://github.com/modderme123/reactively).

Flutter web demo([source](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib)): https://flutter-beacon.surge.sh/
<br>All examples: https://github.com/jinyus/dart_beacon/tree/main/examples

<p align="center">
  <img src="https://github.com/jinyus/dart_beacon/blob/main/assets/state_beacon_demo.jpg?raw=true">
</p>

## Installation

```bash
dart pub add state_beacon
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

final name = Beacon.writable("Bob");

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    // rebuilds whenever the name changes
    return Text(name.watch(context));
  }
}
```

#### Using an asynchronous function

```dart
final counter = Beacon.writable(0);

// The future will be recomputed whenever the counter changes
final futureCounter = Beacon.future(() async {
  final count = counter.value;
  return await fetchData(count);
});

Future<String> fetchData(int count) async {
  await Future.delayed(Duration(seconds: count));
  return '$count second has passed.';
}

class FutureCounter extends StatelessWidget {
  const FutureCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (futureCounter.watch(context)) {
      AsyncData<String>(value: final v) => Text(v),
      AsyncError(error: final e) => Text('$e'),
      _ => const CircularProgressIndicator(),
    };
  }
}
```

## Features

-   [Beacon.writable](#beaconwritable): Mutable beacon that allows both reading and writing.
-   [Beacon.readable](#beaconreadable): Immutable beacon that only emit values, ideal for readonly data.
-   [Beacon.derived](#beaconderived): Derive values from other beacons, keeping them reactively in sync.
-   [Beacon.effect](#beaconeffect): React to changes in beacon values.
-   [Beacon.future](#beaconfuture): Derive values from asynchronous operations, managing state during computation.
    -   [Properties](#properties)
    -   [Methods](#methods)
-   [BeaconGroup](#beacongroup): Create, reset and dispose and group of beacons.
-   [BeaconController](#beaconcontroller)
-   [Dependency Injection](#dependency-injection)
-   [Beacon.stream](#beaconstream): Create derived beacons from Dart streams. values are wrapped in an `AsyncValue`.
-   [Beacon.streamRaw](#beaconstreamraw): Like `Beacon.stream`, but it doesn't wrap the value in an `AsyncValue`.
-   [Beacon.debounced](#beacondebounced): Delay value updates until a specified time has elapsed, preventing rapid or unwanted updates.
-   [Beacon.throttled](#beaconthrottled): Limit the frequency of value updates, ideal for managing frequent events or user input.
-   [Beacon.filtered](#beaconfiltered): Update values based on filter criteria.
-   [Beacon.timestamped](#beacontimestamped): Attach timestamps to each value update.
-   [Beacon.undoRedo](#beaconundoredo): Provides the ability to undo and redo value changes.
-   [Beacon.bufferedCount](#beaconbufferedcount): Create a buffer/list of values based an `int` limit.
-   [Beacon.bufferedTime](#beaconbufferedtime): Create a buffer/list of values based on a time limit.
-   [Beacon.list](#beaconlist): Manage reactive lists that automatically update dependent beacons upon changes.
    -   [Beacon.hashSet](#beaconhashset)
    -   [Beacon.hashMap](#beaconhashmap)
-   [AsyncValue](#asyncvalue): A wrapper around a value that can be in one of four states: `idle`, `loading`, `data`, or `error`.
    -   [unwrap](#asyncvalueunwrap): Casts this [AsyncValue] to [AsyncData] and return its value.
    -   [lastData](#asyncvaluelastdata): Returns the latest valid data value or null.
    -   [tryCatch](#asyncvaluetrycatch): Execute a future and return [AsyncData] or [AsyncError].
    -   [optimistic updates](#asyncvaluetrycatch): Update the value optimistically when using tryCatch.
-   [Beacon.family](#beaconfamily): Create and manage a family of related beacons.
-   [Methods](#properties-and-methods): Additional methods for beacons that can be chained.
    -   [subscribe()](#mybeaconsubscribe)
    -   [tostream()](#mybeacontostream)
    -   [wrap()](#mywritablewrapanybeacon)
    -   [ingest()](#mywritableingestanystream)
    -   [next()](#mybeaconnext)
    -   [toListenable()](#mybeacontolistenable)
    -   [toValueNotifier()](#mybeacontovaluenotifier)
    -   [dispose()](#mybeacondispose)
    -   [onDispose()](#mybeaconondispose)
-   [Chaining Beacons](#chaining-methods): Seamlessly chain beacons to create sophisticated reactive pipelines, combining multiple functionalities for advanced value manipulation and control.
    -   [buffer](#mybeaconbuffer)
    -   [bufferTime](#mybeaconbuffertime)
    -   [throttle](#mybeaconthrottle)
    -   [filter](#mybeaconfilter)
    -   [map](#mybeaconmap)
    -   [debounce](#mybeacondebounce)
-   [Debugging](#debugging)
-   [Disposal](#disposal)
-   [BeaconScheduler](#beaconscheduler): Configure the scheduler for all beacons.
-   [Testing](#testing)

[Pitfalls](#pitfalls)

### Beacon.writable:

A `WritableBeacon` is a mutable reactive value that notifies listeners when its value changes. You might think it's just a `ValueNotifier`, but the power in beacons/signals is their composability.

```dart
final counter = Beacon.writable(0);
counter.value = 10;
print(counter.value); // 10
```

### Beacon.lazyWritable:

Like `Beacon.writable` but behaves like a `late` variable. It must be set before it's read.

#### NB: All writable beacons have a lazy counterpart.

```dart
final counter = Beacon.lazyWritable();

print(counter.value); // throws UninitializeLazyReadException()

counter.value = 10;
print(counter.value); // 10
```

### Beacon.readable:

This is useful for exposing a `WritableBeacon`'s value to consumers without allowing them to modify it. This is the superclass of all beacons.

```dart
final _internalCounter = Beacon.writable(10);

// Expose the beacon's value without allowing it to be modified
ReadableBeacon<int> get counter => _internalCounter;
```

### Beacon.derived:

A `DerivedBeacon` is composed of other beacons. It automatically tracks any beacons accessed within its closure and will recompute its value when one of them changes.

These beacons are lazy and will only compute their value when accessed, subscribed to or being watched by a widget or an [effect](#beaconeffect).

Example:

```dart
final age = Beacon.writable(18);
final canDrink = Beacon.derived(() => age.value >= 21);

canDrink.subscribe((value) {
  print(value); // Outputs: false
});

// Outputs: false

age.value = 22;
// the derived beacon will be updated and the subscribers are notified

// Outputs: true
```

### Beacon.effect:

An effect is just a function that will re-run whenever one of its
dependencies change.

Any beacon accessed within the effect will be tracked as a dependency. A change to the value of any of the tracked beacons will trigger the effect to re-run.

An effect is scheduled to run immediately after creation.

```dart
final age = Beacon.writable(15);

// this effect runs immediately and whenever age changes
Beacon.effect(() {
    if (age.value >= 18) {
      print("You can vote!");
    } else {
       print("You can't vote yet");
    }
 });

// Outputs: "You can't vote yet"

age.value = 20; // Outputs: "You can vote!"
```

### Beacon.future:

Creates a `FutureBeacon` whose value is derived from an asynchronous computation.
This beacon will recompute its value every time one of its dependencies change.
The result is wrapped in an `AsyncValue`, which can be in one of four states: `idle`, `loading`, `data`, or `error`.

If `manualStart` is `true` (default: false), the beacon will be in the `idle` state and the future will not execute until `start()` is called. Calling `start()` on a beacon that's already started will have no effect.

If `shouldSleep` is `true`(default), the callback will not execute if the beacon is no longer being watched.
It will resume executing once a listener is added or its value is accessed.
This means that it will enter the `loading` state when woken up.

NB: You can access the last successful data while the beacon is in the `loading` or `error` state using `myFutureBeacon.lastData`. Calling `lastdata` while in the `data` state will return the current value.

> [!IMPORTANT]
> Only beacons accessed before the async gap will be tracked as dependencies. See [pitfalls](#pitfalls) for more details.

Example:

```dart
final pageNum = Beacon.writable(1);

// The future will be recomputed whenever the counter changes
final pageArticles = Beacon.future(() async {
  final currentPage = pageNum.value;
  final articles = await articleService.getByPage(currentPage)
  return articles;
});

class ArticlesPage extends StatelessWidget {
const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (pageArticles.watch(context)) {
      AsyncData data => ArticleList(data.value),
      AsyncError(error: final e) => Text('$e'),
      AsyncLoading() || AsyncIdle() => const CircularProgressIndicator(),
    };
  }
}
```

Can be transformed into a future with `myFutureBeacon.toFuture()`
This can useful when a FutureBeacon depends on another FutureBeacon.
This functionality is also available to StreamBeacons.

```dart
final isAdminBeacon  = Beacon.writable(false);

var firstName = Beacon.future(() async {
  await Future.delayed(k10ms);
  return 'Sally';
});

var lastName = Beacon.future(() async {
  await Future.delayed(k10ms);
  return 'Smith';
});

var fullName = Beacon.future(() async {
  // wait for the future to complete
  // we don't have to manually handle all the states
  final [fname, lname] = await Future.wait(
    [
      firstName.toFuture(),
      lastName.toFuture(),
    ],
  );

  return '$fname $lname';
});
```

#### FutureBeacon.overrideWith:

Replaces the current callback and resets the beacon by running the new callback.

```dart
var futureBeacon = Beacon.future(() async => 1);

await Future.delayed(k1ms);

expect(futureBeacon.unwrapValue(), 1);

futureBeacon.overrideWith(() async => throw Exception('error'));

await Future.delayed(k1ms);

expect(futureBeacon.isError, true);
```

#### FutureBeacon.updateWith:

The `updateWith` method allows you to update a FutureBeacon's value with the provided callback. This differs from `overrideWith` because it updates the value only once, while `overrideWith` replaces the original callback supplied to the beacon.

```dart
Future<List<Todo>> loadTodos() async { ... }

Future<List<Todo>> addTodo(Todo newTodo) async {
  await todoService.addTodo(newTodo);
  final currentTodos = todosBeacon.lastData ?? [];
  return [newTodo, ...currentTodos];
}

final todosBeacon = Beacon.future(() => loadTodos());

// Later, add a new todo without refetching all todos
await todosBeacon.updateWith(() => addTodo(newTodo));

// You can also provide an optimistic result
// which will be set immediately while the future is being resolved.
final optimisticTodos = [newTodo, ...todosBeacon.lastData ?? []];
await todosBeacon.updateWith(
  () => addTodo(newTodo),
  optimisticResult: optimisticTodos,
);
```

#### Properties:

All these methods are also available to `StreamBeacons`.

-   `isIdle`
-   `isLoading`
-   `isIdleOrLoading`
-   `isData`
-   `isError`
-   `lastData`: Returns the last successful data value or null. This is useful when you want to display the last valid value while refreshing.

#### Methods:

All these methods with the exception on `reset()` and `overrideWith()` are also available to `StreamBeacons`.

-   `start()`: Starts the future if it's in the `idle` state.
-   `reset()`: Resets the beacon by running the callback again. This will enter the `loading` state immediately.
-   `unwrapValue()`: Returns the value if the beacon is in the `data` state. This will throw an error if the beacon is not in the `data` state.
-   `unwrapValueOrNull()`: This is like `unwrapValue()` but it returns null if the beacon is not in the `data` state.
-   `toFuture()`: Returns a future that completes with the value when the beacon is in the `data` state. This will throw an error if the beacon is not in the `data` state.
-   `overrideWith()`: Replaces the current callback and resets the beacon by running the new callback.
-   `updateWith()`: Updates the beacon with the result of the provided future callback.


## BeaconGroup:

An alternative to the global beacon creator ie: `Beacon.writable(0)`; that
keeps track of all beacons and effects created so they can be disposed/reset together.
This is useful when you're creating multiple beacons in a stateful widget or controller class
and want to dispose them together. See [BeaconController](#beaconcontroller).

```dart
 final myGroup = BeaconGroup();

 final name = myGroup.writable('Bob');
 final age = myGroup.writable(20);

 myGroup.effect(() {
   print(name.value); // Outputs: Bob
 });

 age.value = 21;
 name.value = 'Alice';

 myGroup.resetAll(); // reset beacons but does nothing to the effect

 print(name.value); // Bob
 print(age.value); // 20

 myGroup.disposeAll();

 print(name.isDisposed); // true
 print(age.isDisposed); // true
 // All beacons and effects are disposed
```

## BeaconController

An abstract mixin class that automatically disposes all beacons and effects created within it. This can be used to create a controller that manages a group of beacons. use the included [BeaconGroup](#beacongroup)(`B.writable()`) instead of `Beacon.writable()` to create beacons and effects.

NB: All beacons must be created as a `late` variable.

```dart
class CountController extends BeaconController {
  late final count = B.writable(0);
  late final doubledCount = B.derived(() => count.value * 2);
}
```

## Dependency Injection

Dependency injection refers to the process of providing an instance of a Beacon or BeaconController to your widgets. `state_beacon` ships with a lightweight dependency injection library called [lite_ref](https://pub.dev/packages/lite_ref) that makes it easy and ergonomic to do this while also managing disposal of both.

NB: You can use another DI library such as `Provider`.

In the example below, the controller will be disposed when the `CounterText` is unmounted:

```dart
class CountController extends BeaconController {
  late final count = B.writable(0);
  late final doubledCount = B.derived(() => count.value * 2);
}

final countControllerRef = Ref.scoped((ctx) => CountController());

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    // watch the count beacon and return its value
    final count = countControllerRef.select(context, (c) => c.count);
    return Text('$count');
  }
}
```

```dart
final count = countControllerRef.select(context, (c) => c.count);

// is equivalent to
final controller = countControllerRef.of(context);
final count = controller.count.watch(context);
```

You can also use `select2` and `select3` to watch multiple beacons at once.

```dart
final (count, doubledCount) = countControllerRef.select2(context, (c) => (c.count, c.doubledCount));

// is equivalent to
final controller = countControllerRef.of(context);
final count = controller.count.watch(context);
final doubledCount = controller.doubledCount.watch(context);
```

See the full example with testing [here](https://github.com/jinyus/dart_beacon/blob/main/examples/counter/lib/main.dart).

You can also use `Ref.scoped` if you wish to provide a top level beacon without putting it in a controller. The beacon will be properly disposed when all widgets that use it are unmounted.

```dart
final countRef = Ref.scoped((ctx) => Beacon.writable(0));
final doubledCountRef = Ref.scoped((ctx) => Beacon.derived(() => countRef(ctx).value * 2));

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final count = countRef.watch(context);
    final doubledCount = doubledCountRef.watch(context);
    return Text('$count x 2 = $doubledCount');
  }
}
```

> [!NOTE]
> Even though this is possible, it is recommended to use `BeaconController`s whenever possible. In cases where you only need a single beacon, this can be a convenient way to provide it to a widget.


## Other Beacons

### Beacon.stream:

Creates a `StreamBeacon` from a given stream.
When a dependency changes, the beacon will unsubscribe from the old stream and subscribe to the new one.
This beacon updates its value based on the stream's emitted values.
The emitted values are wrapped in an `AsyncValue`, which can be in one of 4 states:`idle`, `loading`, `data`, or `error`.

If `shouldSleep` is `true`(default), it will unsubscribe from the stream if it's no longer being watched.
It will resubscribe once a listener is added or its value is accessed.
This means that it will enter the `loading` state when woken up.

Can be transformed into a future with `mystreamBeacon.toFuture()`:

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.stream(() => myStream);

myBeacon.subscribe((value) {
  print(value); // Outputs AsyncLoading(),AsyncData(0),AsyncData(1),AsyncData(2),...
});
```

### Beacon.streamRaw:

Like `Beacon.stream`, but it doesn't wrap the value in an `AsyncValue`.
When a dependency changes, the beacon will unsubscribe from the old stream and subscribe to the new one.

If `shouldSleep` is `true`(default), it will unsubscribe from the stream if it's no longer being watched.
It will resubscribe once a listener is added or its value is accessed.

One of the following must be `true` if an initial value isn't provided:

1. The type is nullable
2. `isLazy` is true (beacon must be set before it's read from)

```dart
var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);

var myBeacon = Beacon.streamRaw(() => myStream, initialValue: 0);

myBeacon.subscribe((value) {
  print(value); // Outputs 0,1,2,3,...
});
```

### Beacon.debounced:

Creates a `DebouncedBeacon` that will delay updates to its value based on the duration. This is useful when you want to wait until a user has stopped typing before performing an action.

```dart
var query = Beacon.debounced('', duration: Duration(seconds: 1));

query.subscribe((value) {
  print(value); // Outputs: 'apple' after 1 second
});

// simulate user typing
query.value = 'a';
query.value = 'ap';
query.value = 'app';
query.value = 'appl';
query.value = 'apple';

// after 1 second, the value will be updated to 'apple'
```

### Beacon.throttled:

Creates a `ThrottledBeacon` that will limit the rate of updates to its value based on the duration.

If `dropBlocked` is `true`(default), values will be dropped while the beacon is blocked, otherwise, values will be buffered and emitted one by one when the beacon is unblocked.

```dart
const k10ms = Duration(milliseconds: 10);
var beacon = Beacon.throttled(10, duration: k10ms);

beacon.set(20);
expect(beacon.value, equals(20)); // first update allowed

beacon.set(30);
expect(beacon.value, equals(20)); // too fast, update ignored

await Future.delayed(k10ms * 1.1);

beacon.set(30);
expect(beacon.value, equals(30)); // throttle time passed, update allowed
```

### Beacon.filtered:

Creates a `FilteredBeacon` that will only updates its value if it passes the filter criteria.
The filter function receives the previous and new values as arguments.
The filter function can also be changed using the `setFilter` method.

#### Simple Example:

```dart
// only positive values are allowed
var pageNum = Beacon.filtered(10, filter: (prev, next) => next > 0);
pageNum.value = 20; // update is allowed
pageNum.value = -5; // update is ignored
```

#### Example when filter function depends on another beacon:

In this example, `posts` is a derived future beacon that will fetch the posts whenever `pageNum` changes.
We want to prevent the user from changing `pageNum` while `posts` is loading.

```dart
var pageNum = Beacon.filtered(1); // we will set the filter function later

final posts = Beacon.future(() => Repository.getPosts(pageNum.value));

// can't change pageNum while loading
pageNum.setFilter((prev, next) => !posts.isLoading);
```

Extracted from the [infinite list example](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib/infinite_list)

### Beacon.timestamped:

Creates a `TimestampBeacon` that attaches a timestamp to each value update.

```dart
var myBeacon = Beacon.timestamped(10);
print(myBeacon.value); // Outputs: (value: 10, timestamp: __CURRENT_TIME__)
```

### Beacon.undoRedo:

Creates an `UndoRedoBeacon` that allows undoing and redoing changes to its value.

```dart
var age = Beacon.undoRedo(0, historyLimit: 10);

age.value = 10;
age.value = 20;

age.undo(); // Reverts to 10
age.redo(); // Goes back to 20
```

### Beacon.bufferedCount:

Creates a `BufferedCountBeacon` that collects and buffers a specified number
of values. Once the count threshold is reached, the beacon's value is updated
with the list of collected values and the buffer is reset.

This beacon is useful in scenarios where you need to aggregate a certain
number of values before processing them together.

```dart
var countBeacon = Beacon.bufferedCount<int>(3);

countBeacon.subscribe((values) {
  print(values);
});

countBeacon.add(1);
countBeacon.add(2);
countBeacon.add(3); // Triggers update and prints [1, 2, 3]
```

You may also access the `currentBuffer` as a readable beacon.
See it in use in the [konami example](https://github.com/jinyus/dart_beacon/tree/main/examples/flutter_main/lib/konami);

### Beacon.bufferedTime:

Creates a `BufferedTimeBeacon` that collects values over a specified time duration.
Once the time duration elapses, the beacon's value is updated with the list of
collected values and the buffer is reset.

```dart
var timeBeacon = Beacon.bufferedTime<int>(duration: Duration(seconds: 5));

timeBeacon.subscribe((values) {
  print(values);
});

timeBeacon.add(1);
timeBeacon.add(2);
// After 5 seconds, it will output [1, 2]
```

### Beacon.list:

The `ListBeacon` provides methods to add, remove, and update items in the list and notifies listeners without having to make a copy.

_NB_: The `previousValue` and current value will always be the same because the same list is being mutated. If you need access to the previousValue, use Beacon.writable<List>([]) instead.

#### Beacon.hashSet:

Similar to Beacon.list(), but for Sets.

```dart
var uniqueNumbers = Beacon.hashSet<int>({1, 2, 3});

Beacon.effect(() {
  print(uniqueNumbers.value); // Outputs: {1, 2, 3}
});

uniqueNumbers.add(4); // Outputs: {1, 2, 3, 4}

uniqueNumbers.remove(2); // Outputs: {1, 3, 4}
```

#### Beacon.hashMap:

Similar to Beacon.list(), but for Maps.

```dart
var userMap = Beacon.hashMap<String, int>({});

Beacon.effect(() {
  print(userMap.value); // Outputs: {}
});

userMap['Alice'] = 25; // Outputs: {Alice: 25}

userMap['Bob'] = 30; // Outputs: {Alice: 25, Bob: 30}

userMap.remove('Alice'); // Outputs: {Bob: 30}
```

### AsyncValue:

An `AsyncValue` is a wrapper around a value that can be in one of four states:`idle`, `loading`, `data`, or `error`.
This is the value type of [FutureBeacons](#beaconfuture),[FutureBeacons](#beaconfuture) and [StreamBeacons](#beaconstream).

```dart
var myBeacon = Beacon.future(() async {
  return await Future.delayed(Duration(seconds: 1), () => 'Hello');
});

print(myBeacon.value); // Outputs AsyncLoading immediately

await Future.delayed(Duration(seconds: 1));

print(myBeacon.value); // Outputs AsyncData('Hello')
```

#### AsyncValue.unwrap():

Casts this [AsyncValue] to [AsyncData] and return its value. This will throw an error if the value is not an [AsyncData].

```dart
var name = AsyncData('Bob');
print(name.unwrap()); // Outputs: Bob

name = AsyncLoading();
print(name.unwrap()); // Throws error
```

#### AsyncValue.lastData:

Returns the latest valid data value or null. This is useful when you want to display the last valid value while loading new data.

```dart
var myBeacon = Beacon.future(() async {
  return await Future.delayed(Duration(seconds: 1), () => 'Hello');
});

print(myBeacon.value); // Outputs AsyncLoading immediately

print(myBeacon.value.lastData); // Outputs null as there is no valid data yet

await Future.delayed(Duration(seconds: 1));

print(myBeacon.value.lastData); // Outputs 'Hello'

myBeacon.reset();

print(myBeacon.value); // Outputs AsyncLoading

print(myBeacon.value.lastData); // Outputs 'Hello' as the last valid data when in loading state
```

#### AsyncValue.tryCatch:

Executes the future provided and returns [AsyncData] with the result
if successful or [AsyncError] if an exception is thrown.

Supply an optional [WritableBeacon] that will be set throughout the
various states.

Supply an optional [optimisticResult] that will be set while loading, instead of [AsyncLoading].

```dart
Future<String> fetchUserData() {
  // Imagine this is a network request that might throw an error
  return Future.delayed(Duration(seconds: 1), () => 'User data');
}
  beacon.value = AsyncLoading();
  beacon.value = await AsyncValue.tryCatch(fetchUserData);
```

You can also pass the beacon as a parameter.
`loading`,`data` and `error` states,
as well as the last successful data will be set automatically.

```dart
await AsyncValue.tryCatch(fetchUserData, beacon: beacon);

// or use the extension method.

await beacon.tryCatch(fetchUserData);
```

See it in use in the [shopping cart example](https://github.com/jinyus/dart_beacon/tree/main/examples/shopping_cart/lib/src/cart).

If you want to do optimistic updates, you can supply an optional `optimisticResult` parameter.

```dart
await beacon.tryCatch(mutateUserData, optimisticResult: 'User data');
```

Without `tryCatch`, handling the potential error requires more
boilerplate code:

```dart
  beacon.value = AsyncLoading();
  try {
    beacon.value = AsyncData(await fetchUserData());
  } catch (err,stacktrace) {
    beacon.value = AsyncError(err, stacktrace);
  }
```

## Beacon.family:

Creates and manages a family of related `Beacon`s based on a single creation function.

This class provides a convenient way to handle related
beacons that share the same creation logic but have different arguments.

### Type Parameters:

-   `T`: The type of the value emitted by the beacons in the family.
-   `Arg`: The type of the argument used to identify individual beacons within the family.
-   `BeaconType`: The type of the beacon in the family.

If `cache` is `true`, created beacons are cached. Default is `false`.

Example:

```dart
final postContentFamily = Beacon.family(
 (String id) {
   return Beacon.future(() async {
     return await Repository.getPostContent(id);
   });
 },
);


final postContent = postContentFamily('post-1');
final postContent = postContentFamily('post-2');

postContent.subscribe((value) {
  print(value); // Outputs: post content
});
```

## Properties and Methods:

### myBeacon.value:

The current value of the beacon. This beacon will be registered as a dependency if accessed within a derived beacon or an effect. Aliases: `myBeacon()`, `myBeacon.call()`.

### myBeacon.peek():

Returns the current value of the beacon without registering it as a dependency.

### myBeacon.watch(context):

Returns the current value of the beacon and rebuilds the widgets whenever the beacon is updated.

```dart
final name = Beacon.writable("Bob");

class ProfileCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // rebuilds whenever the name changes
    return Text(name.watch(context));
  }
}
```

### myBeacon.observe(context,callback):

Executes the callback (side effect) whenever the beacon is updated. eg: Show a snackbar when the value changes.

```dart
final name = Beacon.writable("Bob");

class ProfileCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    name.observe(context, (prev, next) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('name changed from $prev to $next')),
      );
    });

    return Text(name.watch(context));
  }
}
```

### myBeacon.subscribe():

Subscribes to the beacon and listens for changes to its value.

```dart

final age = Beacon.writable(20);

age.subscribe((value) {
  print(value); // Outputs: 21, 22, 23
});

age.value = 21;
age.value = 22;
age.value = 23;
```

### myBeacon.stream:

This returns a stream that emits the beacon's value whenever it changes.

### myWritable.wrap(anyBeacon):

Wraps an existing beacon and consumes its values

Supply a (`then`) function to customize how the emitted values are
processed.

```dart
var bufferBeacon = Beacon.bufferedCount<String>(10);
var count = Beacon.writable(5);

// Wrap the bufferBeacon with the readableBeacon and provide a custom transformation.
bufferBeacon.wrap(count, then: (value) {
  // Custom transformation: Convert the value to a string and add it to the buffer.
  bufferBeacon.add(value.toString());
});

print(bufferBeacon.buffer); // Outputs: ['5']
count.value = 10;
print(bufferBeacon.buffer); // Outputs: ['5', '10']
```

This method is available on all writable beacons, including BufferedBeacons; and can wrap any beacon since all beacons are readable.

### myWritable.ingest(anyStream):

This functions like `.wrap()` but it's specifically for streams. It listens to the stream and updates the beacon's value with the emitted values.

```dart
final beacon = Beacon.writable(0);
final myStream = Stream.fromIterable([1, 2, 3]);

beacon.ingest(myStream);

beacon.subscribe((value) {
  print(value); // Outputs: 1, 2, 3
});
```

### mybeacon.next():

Listens for the next value emitted by this Beacon and returns it as a Future.

This method subscribes to this Beacon and waits for the next value
that matches the optional [filter] function. If [filter] is provided and
returns `false` for a emitted value, the method continues waiting for the
next value that matches the filter. If no [filter] is provided,
the method completes with the first value received.

If this is a lazy beacon and it's disposed before a value is emitted,
the future will be completed with an error if a [fallback] value is not provided.

```dart
final age = Beacon.writable(20);

Timer(Duration(seconds: 1), () => age.value = 21;);

final nextAge = await age.next(); // returns 21 after 1 second
```

### mybeacon.toListenable():

Returns a `ValueListenable` that emits the beacon's value whenever it changes.

### mybeacon.toValueNotifier():

Returns a `ValueNotifier` that emits the beacon's value whenever it changes. Any mutations to the `ValueNotifier` will be reflected in the beacon. The `ValueNotifier` will be disposed when the beacon is disposed.

### mybeacon.dispose():

Disposes the beacon and releases all resources.

### mybeacon.onDispose():

Registers a callback to be called when the beacon is disposed. Returrns a function that can be called to unregister the callback.

## Chaining methods:

Seamlessly chain beacons to create sophisticated reactive pipelines, combining multiple functionalities for advanced value manipulation and control.

```dart
// every write to this beacon will be filtered then debounced.
final searchQuery = Beacon.writable('').filter((prev, next) => next.length > 2).debounce(duration: k500ms);
```

> [!IMPORTANT]  
> When chaining beacons, all writes made to the returned beacon will be re-routed to the first writable beacon in the chain. It is recommended to mutate the source beacons directly.

```dart
const k500ms = Duration(milliseconds: 500);

final count = Beacon.writable(10);

final filteredCount = count
        .debounce(duration: k500ms),
        .filter((prev, next) => next > 10);

filteredCount.value = 20;
// The mutation will be re-routed to count
// before being passed to the debounced beacon
// then to the filtered beacon.
// This is equivalent to count.value = 20;

expect(count.value, equals(20));

await Future.delayed(k500ms);

expect(filteredCount.value, equals(20));
```

> [!WARNING]  
> `buffer` and `bufferTime` cannot be mid-chain. If they are used, they **MUST** be the last in the chain.

```dart
// GOOD
someBeacon.filter().buffer(10);

// BAD
someBeacon.buffer(10).filter();
```

### mybeacon.buffer():

Returns a [Beacon.bufferedCount](#beaconbufferedcount) that wraps this beacon.

NB: The returned beacon will be disposed when the wrapped beacon is disposed.

```dart
final age = Beacon.writable(20);

final bufferedAge = age.buffer(10);

bufferedAge.subscribe((value) {
  print(value); // Outputs: [20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
});

for (var i = 0; i < 10; i++) {
  age.value++;
}
```

### mybeacon.bufferTime():

Returns a [Beacon.bufferedTime](#beaconbufferedtime) that wraps this beacon.

### mybeacon.throttle():

Returns a [Beacon.throttled](#beaconthrottled) that wraps this beacon.

### mybeacon.filter():

Returns a [Beacon.filtered](#beaconfiltered) that wraps this beacon.

### mybeacon.map():

Returns a [ReadableBeacon] that wraps a Beacon and tranforms its values.

```dart
final stream = Stream.periodic(k1ms, (i) => i).take(5);
final beacon = stream
    .toRawBeacon(isLazy: true)
    .map((v) => v.toString());

await expectLater(beacon.stream, emitsInOrder(['0', '1', '2', '3', '4']));
```

> [!NOTE]
> When `map` returns a different type, writes to the returned beacon will not be re-routed to the original beacon. In the example below, writes to `filteredBeacon` will NOT be re-routed to `count` because `map` returns a `String`; which means the type of the returned beacon is `FilteredBeacon<String>` and `count` holds an `int`.

```dart
final count = Beacon.writable(0);
final filteredBeacon = count.map((v) => '$v').filter((_, n) => n.length > 1);
```

### mybeacon.debounce():

Returns a [Beacon.debounced](#beacondebounced) that wraps this beacon.

```dart
final query = Beacon.writable('');

const k500ms = Duration(milliseconds: 500);

final debouncedQuery = query
        .filter((prev, next) => next.length > 2)
        .debounce(duration: k500ms);
```

## Debugging:

Set the global `BeaconObserver` instance to get notified of all beacon creation, updates and disposals. You can also see when a derived beacon or effect starts/stops watching a beacon.

You can create your own observer by implementing `BeaconObserver` or use the provided logging observer, which logs to the console. Provide a `name` to your beacons to make it easier to identify them in the logs.

```dart
BeaconObserver.instance = LoggingObserver(); // or BeaconObserver.useLogging()

var a = Beacon.writable(10, name: 'a');
var b = Beacon.writable(20, name: 'b');
var c = Beacon.derived(() => a() * b(), name: 'c');

Beacon.effect(
  () {
    print('c: ${c.value}');
  },
  name: 'printEffect',
);
```

This will log:

```
Beacon created: a
Beacon created: b
Beacon created: c

"printEffect" is watching "c"

"c" is watching "a"
"c" is watching "b"

"c" was updated:
  old: null
  new: 200
```

Updating a beacon:

```dart
a.value = 15;
```

This will log:

```
"a" was updated:
  old: 10
  new: 15

"c" was updated:
  old: 200
  new: 300
```

Disposing a beacon

```dart
c.dispose();
```

This will log:

```
"c" stopped watching "a"
"c" stopped watching "b"

"c" was disposed
"printEffect" stopped watching c
```

## Disposal

When a beacon is disposed, all downstream derived beacons and effects will be disposed as well.
A beacon cannot be updated after it's disposed. An assertion error will be thrown if you try to update a disposed beacon.
A warning will be logged in debug mode if you try to access the value of a disposed beacon.
A beacon should be disposed when it's no longer needed to free up resources.

In the example below, when `a` is disposed, `c` and `effect` will also be disposed.

```
  a      b
   \    /
    \  /
     c
     |
     |
   effect
```

```dart
final a = Beacon.writable(10);
final b = Beacon.writable(10);
final c = Beacon.derived(() => a.value * b.value);

Beacon.effect(() => print(c.value));

//...//

a.dispose();

expect(a.isDisposed, true);
expect(c.isDisposed, true);
// effect is also disposed
```

### BeaconScheduler:

`Effects` and `Subscriptions` are not synchronous, their execution is controlled by a scheduler. When a dependency of an `effect` changes, it is added to a queue and the scheduler decides when is the best time to flush the queue. By default, the queue is flushed with a DARTVM microtask which runs on the next loop; this can be changed by setting a custom scheduler.

A 60fps scheduler is included, this limits processing effects to 60 times per second. This can be done by calling `BeaconScheduler.use60FpsScheduler();` in the `main` function. You can also create your own custom scheduler for more advanced use cases. eg: `Gaming`: Synchronize flushing with your game loop.

When testing **synchronous** code, it is necessary to flush the queue manually. This can be done by calling `BeaconScheduler.flush();` in your test.

> [!NOTE]
> When writing widget tests, manual flushing isn't needed. The queue is automatically flushed when you call `tester.pumpAndSettle()`.

```dart
final a = Beacon.writable(10);
var called = 0;

// effect is queued for execution. The scheduler decides when to run the effect
Beacon.effect(() {
      print("current value: ${a.value}");
      called++;
});

// manually flush the queue to run the all effect immediately
BeaconScheduler.flush();

expect(called, 1);

a.value = 20; // effect will be queued again.

BeaconScheduler.flush();

expect(called, 2);
```

## Testing

Beacons can expose a `Stream` with the `.stream` method. This can be used to test the state of a beacon over time with existing `StreamMatcher`s.

```dart
final count = Beacon.writable(10);

final stream = count.stream;

Future.delayed(Duration(milliseconds: 1), () => count.value = 20);

expect(stream, emitsInOrder([10, 20]));
```

### Testing beacons with chaining methods

[Chaining](#chaining-methods) methods (`buffer`, `bufferTime`, `next`) can be used to make testing easier.

##### anyBeacon.buffer()

```dart
final count = Beacon.writable(10);

final buff = count.buffer(2);

count.value = 20;

expect(buff.value, equals([10, 20]));
```

##### anyBeacon.next()

```dart
final count = Beacon.writable(10);

expectLater(count.next(), completion(30));

count.value = 30;
```

##### anyBeacon.bufferTime().next()

```dart
final count = Beacon.writable(10);

final buffTime = count.bufferTime(duration: Duration(milliseconds: 10));

expectLater(buffTime.next(), completion([10, 20, 30, 40]));

count.value = 20;
count.value = 30;
count.value = 40;
```

### BeaconControllerMixin

A mixin for `StatefulWidget`'s `State` class that automatically disposes all beacons and effects created within it.

```dart
class MyController extends StatefulWidget {
  const MyController({super.key});

  @override
  State<MyController> createState() => _MyControllerState();
}

class _MyControllerState extends State<MyController>
    with BeaconControllerMixin {
  // NO need to dispose these manually
  late final count = B.writable(0);
  late final doubledCount = B.derived(() => count.value * 2);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## TextEditingBeacon

A beacon that wraps a `TextEditingController`. All changes to the controller are reflected in the beacon and vice versa.

```dart
final beacon = TextEditingBeacon();
final controller = beacon.controller;

controller.text = 'Hello World';
print(beacon.value.text); // Outputs: Hello World
```

## Pitfalls

When using `Beacon.future`, only beacons accessed before the async gap(`await`) will be tracked as dependencies.

```dart
final counter = Beacon.writable(0);
final doubledCounter = Beacon.derived(() => counter.value * 2);

final futureCounter = Beacon.future(() async {
  // This will be tracked as a dependency because it's accessed before the async gap
  final count = counter.value;

  await Future.delayed(Duration(seconds: count));

  // This will NOT be tracked as a dependency because it's accessed after `await`
  final doubled = doubledCounter.value;

  return '$count x 2 =  $doubled';
});
```

When a future depends on multiple future/stream beacons

-   DON'T:

```dart
final futureCounter = Beacon.future(() async {
  // in this instance lastNameStreamBeacon will not be tracked as a dependency
  // because it's accessed after the async gap
  final firstName = await firstNameFutureBeacon.toFuture();
  final lastName = await lastNameStreamBeacon.toFuture();

  return 'Fullname is $firstName $lastName';
});
```

-   DO:

```dart
final futureCounter = Beacon.future(() async {
  // store the futures before the async gap ie: don't use await
  final firstNameFuture = firstNameFutureBeacon.toFuture();
  final lastNameFuture = lastNameStreamBeacon.toFuture();

  // wait for the futures to complete
  final (String firstName, String lastName) = await (firstNameFuture, lastNameFuture).wait;

  return 'Fullname is $firstName $lastName';
});
```
