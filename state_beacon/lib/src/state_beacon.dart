// ignore_for_file: invalid_use_of_protected_member

import 'package:state_beacon/src/beacons/family.dart';
import 'package:state_beacon/src/untracked.dart';

import 'base_beacon.dart';
import 'common.dart';

abstract class Beacon {
  /// Creates a `WritableBeacon` with an initial value.
  /// This beacon allows both reading and writing the value.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.writable(10);
  /// print(myBeacon.value); // Outputs: 10
  /// myBeacon.value = 20;
  /// ```
  static WritableBeacon<T> writable<T>(
    T initialValue, {
    String? debugLabel,
  }) =>
      WritableBeacon<T>(initialValue)
        ..setDebugLabel(debugLabel ?? 'Writable<$T>');

  /// Like `writable`, but the initial value is lazily initialized.
  static WritableBeacon<T> lazyWritable<T>({
    T? initialValue,
    String? debugLabel,
  }) =>
      WritableBeacon<T>(initialValue)
        ..setDebugLabel(debugLabel ?? 'LazyWritable<$T>');

  /// Creates a `ReadableBeacon` with an initial value.
  /// This beacon allows only reading the value.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.readable(15);
  /// print(myBeacon.value); // Outputs: 15
  /// ```
  static ReadableBeacon<T> readable<T>(
    T initialValue, {
    String? debugLabel,
  }) =>
      ReadableBeacon<T>(initialValue)
        ..setDebugLabel(debugLabel ?? 'Readable<$T>');

  /// Returns a `ReadableBeacon` and a function that allows writing to the beacon.
  /// This is useful for creating a beacon that's readable by the public,
  /// but writable only by the owner.
  ///
  /// Example:
  /// ```dart
  /// var (count,setCount) = Beacon.scopedWritable(15);
  /// ```
  static (ReadableBeacon<T>, void Function(T)) scopedWritable<T>(
    T initialValue, {
    String? debugLabel,
  }) {
    final beacon = WritableBeacon<T>(initialValue)
      ..setDebugLabel(debugLabel ?? 'ScopedWritable<$T>');
    return (beacon, beacon.set);
  }

  /// Creates a `DebouncedBeacon` with an initial value and a debounce duration.
  /// This beacon delays updates to its value based on the duration.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.debounced(10, duration: Duration(seconds: 1));
  /// myBeacon.value = 20; // Update is debounced
  /// print(myBeacon.value); // Outputs: 10
  /// await Future.delayed(Duration(seconds: 1));
  /// print(myBeacon.value); // Outputs: 20
  /// ```
  static DebouncedBeacon<T> debounced<T>(
    T initialValue, {
    required Duration duration,
    String? debugLabel,
  }) =>
      DebouncedBeacon<T>(initialValue: initialValue, duration: duration)
        ..setDebugLabel(debugLabel ?? 'DebouncedBeacon<$T>');

  /// Like `debounced`, but the initial value is lazily initialized.
  static DebouncedBeacon<T> lazyDebounced<T>({
    T? initialValue,
    required Duration duration,
    String? debugLabel,
  }) =>
      DebouncedBeacon<T>(initialValue: initialValue, duration: duration)
        ..setDebugLabel(debugLabel ?? 'LazyDebouncedBeacon<$T>');

  /// Creates a `ThrottledBeacon` with an initial value and a throttle duration.
  /// This beacon limits the rate of updates to its value based on the duration.
  /// Updates that occur faster than the throttle duration are ignored.
  ///
  /// If `dropBlocked` is `true`, values will be dropped while the beacon is blocked.
  /// If `dropBlocked` is `false`, values will be buffered and emitted when the beacon is unblocked.
  ///
  /// Example:
  /// ```dart
  /// const k10ms = Duration(milliseconds: 10);
  /// var beacon = Beacon.throttled(10, duration: k10ms);
  ///
  /// beacon.set(20);
  /// expect(beacon.value, equals(20)); // first update allowed
  ///
  /// beacon.set(30);
  /// expect(beacon.value, equals(20)); // too fast, update ignored
  ///
  /// await Future.delayed(k10ms * 1.1);
  ///
  /// beacon.set(30);
  /// expect(beacon.value, equals(30)); // throttle time passed, update allowed
  /// ```

  static ThrottledBeacon<T> throttled<T>(
    T? initialValue, {
    required Duration duration,
    bool dropBlocked = true,
    String? debugLabel,
  }) =>
      ThrottledBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        dropBlocked: dropBlocked,
      )..setDebugLabel(debugLabel ?? 'ThrottledBeacon<$T>');

  /// Like `throttled`, but the initial value is lazily initialized.
  static ThrottledBeacon<T> lazyThrottled<T>({
    T? initialValue,
    required Duration duration,
    bool dropBlocked = true,
    String? debugLabel,
  }) =>
      ThrottledBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        dropBlocked: dropBlocked,
      )..setDebugLabel(debugLabel ?? 'LazyThrottledBeacon<$T>');

  /// Creates a `FilteredBeacon` with an initial value and a filter function.
  /// This beacon updates its value only if it passes the filter criteria.
  /// The filter function receives the previous and new values as arguments.
  /// The filter function can also be changed using the `setFilter` method.
  ///
  /// ### Simple Example:
  /// ```dart
  /// var pageNum = Beacon.filtered(10, (prev, next) => next > 0); // only positive values are allowed
  /// pageNum.value = 20; // update is allowed
  /// pageNum.value = -5; // update is ignored
  /// ```

  /// ### Example when filter function depends on another beacon:
  /// ```dart
  /// var pageNum = Beacon.filtered(1); // we will set the filter function later
  ///
  /// final posts = Beacon.derivedFuture(() async {Repository.getPosts(pageNum.value);});
  ///
  /// pageNum.setFilter((prev, next) => posts.value is! AsyncLoading); // can't change pageNum while loading
  /// ```
  static FilteredBeacon<T> filtered<T>(
    T initialValue, {
    BeaconFilter<T>? filter,
    String? debugLabel,
  }) {
    return FilteredBeacon<T>(initialValue: initialValue, filter: filter)
      ..setDebugLabel(debugLabel ?? 'FilteredBeacon<$T>');
  }

  /// Like `filtered`, but the initial value is lazily initialized.
  /// The first will not be filtered if the `initialValue` is null.
  static FilteredBeacon<T> lazyFiltered<T>({
    T? initialValue,
    BeaconFilter<T>? filter,
    String? debugLabel,
  }) {
    return FilteredBeacon<T>(initialValue: initialValue, filter: filter)
      ..setDebugLabel(debugLabel ?? 'LazyFilteredBeacon<$T>');
  }

  /// Creates a `BufferedCountBeacon` that collects and buffers a specified number
  /// of values. Once the count threshold is reached, the beacon's value is updated
  /// with the list of collected values and the buffer is reset.
  ///
  /// This beacon is useful in scenarios where you need to aggregate a certain
  /// number of values before processing them together.
  ///
  /// Example:
  /// ```dart
  /// var countBeacon = Beacon.bufferedCount(3);
  /// countBeacon.subscribe((values) {
  ///   print(values); // Outputs the list of collected values
  /// });
  /// countBeacon.value = 1;
  /// countBeacon.value = 2;
  /// countBeacon.value = 3; // Triggers update with [1, 2, 3]
  /// ```
  static BufferedCountBeacon<T> bufferedCount<T>(int count,
          {String? debugLabel}) =>
      BufferedCountBeacon<T>(countThreshold: count)
        ..setDebugLabel(debugLabel ?? 'BufferedCountBeacon<$T>');

  /// Creates a `BufferedTimeBeacon` that collects values over a specified time duration.
  /// Once the time duration elapses, the beacon's value is updated with the list of
  /// collected values and the buffer is reset for the next interval.
  ///
  /// This beacon is ideal for scenarios where values need to be batched and processed
  /// periodically over time.
  ///
  /// Example:
  /// ```dart
  /// var timeBeacon = Beacon.bufferedTime<int>(duration: Duration(seconds: 5));
  ///
  /// timeBeacon.subscribe((values) {
  ///   print(values);
  /// });
  ///
  /// timeBeacon.value = 1;
  /// timeBeacon.value = 2;
  /// // After 5 seconds, it will output [1, 2]
  /// ```
  static BufferedTimeBeacon<T> bufferedTime<T>({
    required Duration duration,
    String? debugLabel,
  }) =>
      BufferedTimeBeacon<T>(duration: duration)
        ..setDebugLabel(debugLabel ?? 'BufferedTimeBeacon<$T>');

  /// Creates an `UndoRedoBeacon` with an initial value and an optional history limit.
  /// This beacon allows undoing and redoing changes to its value, up to the specified
  /// number of past states.
  ///
  /// This beacon is particularly useful in scenarios where you need to provide
  /// undo/redo functionality, such as in text editors or form input fields.
  ///
  /// Example:
  /// ```dart
  /// var undoRedoBeacon = UndoRedoBeacon<int>(0, historyLimit: 10);
  /// undoRedoBeacon.value = 10;
  /// undoRedoBeacon.value = 20;
  /// undoRedoBeacon.undo(); // Reverts to 10
  /// undoRedoBeacon.redo(); // Goes back to 20
  /// ```
  static UndoRedoBeacon<T> undoRedo<T>(
    T initialValue, {
    int historyLimit = 10,
    String? debugLabel,
  }) {
    return UndoRedoBeacon<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
    )..setDebugLabel(debugLabel ?? 'UndoRedoBeacon<$T>');
  }

  /// Like `undoRedo`, but the initial value is lazily initialized.
  static UndoRedoBeacon<T> lazyUndoRedo<T>({
    T? initialValue,
    int historyLimit = 10,
    String? debugLabel,
  }) {
    return UndoRedoBeacon<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
    )..setDebugLabel(debugLabel ?? 'LazyUndoRedoBeacon<$T>');
  }

  /// Creates a `TimestampBeacon` with an initial value.
  /// This beacon attaches a timestamp to each value update.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.timestamped(10);
  /// print(myBeacon.value); // Outputs: (value: 10, timestamp: DateTime.now())
  /// ```
  static TimestampBeacon<T> timestamped<T>(T initialValue,
          {String? debugLabel}) =>
      TimestampBeacon<T>(initialValue)
        ..setDebugLabel(debugLabel ?? 'TimestampBeacon<$T>');

  /// Like `timestamped`, but the initial value is lazily initialized.
  static TimestampBeacon<T> lazyTimestamped<T>({
    T? initialValue,
    String? debugLabel,
  }) =>
      TimestampBeacon<T>(initialValue)
        ..setDebugLabel(debugLabel ?? 'LazyTimestampBeacon<$T>');

  /// Creates a `StreamBeacon` from a given stream.
  /// This beacon updates its value based on the stream's emitted values.
  /// The emitted values are wrapped in an `AsyncValue`, which can be in one of three states: loading, data, or error.
  ///
  /// Example:
  /// ```dart
  /// var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// var myBeacon = Beacon.stream(myStream);
  /// myBeacon.subscribe((value) {
  ///   print(value); // Outputs the stream's emitted values
  /// });
  /// ```
  static StreamBeacon<T> stream<T>(
    Stream<T> stream, {
    bool cancelOnError = false,
    String? debugLabel,
  }) {
    return StreamBeacon<T>(
      stream,
      cancelOnError: cancelOnError,
    )..setDebugLabel(debugLabel ?? 'StreamBeacon<$T>');
  }

  /// Like `stream`, but it doesn't wrap the value in an `AsyncValue`.
  /// If you dont supply an initial value, the type has to be nullable.
  static RawStreamBeacon<T> streamRaw<T>(
    Stream<T> stream, {
    bool cancelOnError = false,
    Function? onError,
    Function? onDone,
    T? initialValue,
    String? debugLabel,
  }) {
    return RawStreamBeacon<T>(
      stream,
      cancelOnError: cancelOnError,
      onError: onError,
      onDone: onDone,
      initialValue: initialValue,
    )..setDebugLabel(debugLabel ?? 'RawStreamBeacon<$T>');
  }

  /// Creates a `FutureBeacon` that initializes its value based on a future.
  /// The beacon can optionally depend on another `ReadableBeacon`.
  ///
  /// If `manualStart` is `true`, the future will not execute until [start()] is called.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.future(() async {
  ///   return await Future.delayed(Duration(seconds: 1), () => 'Hello');
  /// });
  /// myBeacon.subscribe((value) {
  ///   print(value); // Outputs 'Hello' after 1 second
  /// });
  /// ```
  static FutureBeacon<T> future<T>(
    Future<T> Function() future, {
    bool manualStart = false,
    bool cancelRunning = true,
    String? debugLabel,
  }) {
    return DefaultFutureBeacon<T>(
      future,
      manualStart: manualStart,
      cancelRunning: cancelRunning,
    )..setDebugLabel(debugLabel ?? 'FutureBeacon<$T>');
  }

  /// Creates a `DerivedBeacon` whose value is derived from a computation function.
  /// This beacon will recompute its value everytime one of it's dependencies change.
  ///
  /// If `manualStart` is `true`, the future will not execute until [start()] is called.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable<int>(18);
  /// final canDrink = Beacon.derived(() => age.value >= 21);
  ///
  /// print(canDrink.value); // Outputs: false
  ///
  /// age.value = 22;
  ///
  /// print(canDrink.value); // Outputs: true
  /// ```
  static DerivedBeacon<T> derived<T>(
    T Function() compute, {
    bool manualStart = false,
    String? debugLabel,
  }) {
    final beacon = DerivedBeacon<T>(manualStart: manualStart)
      ..setDebugLabel(debugLabel ?? 'DerivedBeacon<$T>');

    final unsub = effect(() {
      // beacon is manually triggered if in idle state
      if (beacon.status.value == DerivedStatus.idle) return;

      beacon.forceSetValue(compute());
    });

    beacon.$setInternalEffectUnsubscriber(unsub);

    return beacon;
  }

  /// Creates a `DerivedBeacon` whose value is derived from an asynchronous computation.
  /// This beacon will recompute its value every time one of its dependencies change.
  /// The result is wrapped in an `AsyncValue`, which can be in one of three states: loading, data, or error.
  ///
  /// If `manualStart` is `true`, the future will not execute until [start()] is called.
  ///
  /// If `cancelRunning` is `true`, the results of a current execution will be discarded
  /// if another execution is triggered before the current one finishes.
  ///
  /// Example:
  /// ```dart
  ///   final counter = Beacon.writable(0);
  ///
  ///   // The future will be recomputed whenever the counter changes
  ///   final derivedFutureCounter = Beacon.derivedFuture(() async {
  ///     final count = counter.value;
  ///     await Future.delayed(Duration(seconds: count));
  ///     return '$count second has passed.';
  ///   });
  ///
  ///   class FutureCounter extends StatelessWidget {
  ///   const FutureCounter({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return switch (derivedFutureCounter.watch(context)) {
  ///       AsyncData<String>(value: final v) => Text(v),
  ///       AsyncError(error: final e) => Text('$e'),
  ///       AsyncLoading() => const CircularProgressIndicator(),
  ///     };
  ///   }
  /// }
  /// ```
  static FutureBeacon<T> derivedFuture<T>(
    FutureCallback<T> compute, {
    bool manualStart = false,
    bool cancelRunning = true,
    String? debugLabel,
  }) {
    final beacon = DerivedFutureBeacon<T>(
      compute,
      manualStart: manualStart,
      cancelRunning: cancelRunning,
    )..setDebugLabel(debugLabel ?? 'DerivedFutureBeacon<$T>');

    final unsub = effect(() async {
      // beacon is manually triggered if in idle state
      if (beacon.status.value == DerivedFutureStatus.idle) return;

      await beacon.run();
    });

    beacon.$setInternalEffectUnsubscriber(unsub);

    return beacon;
  }

  /// Creates a `ListBeacon` with an initial list value.
  /// This beacon manages a list of items, allowing for reactive updates and manipulations of the list.
  ///
  /// The `ListBeacon` provides methods to add, remove, and update items in the list and notifies listeners without having to make a copy.
  ///
  /// NB: The `previousValue` and current value will always be the same because the same list is being mutated. If you need access to the previousValue, use Beacon.writable<List>([]) instead.
  ///
  /// Example:
  /// ```dart
  /// var nums = Beacon.list<int>([1, 2, 3]);
  ///
  /// Beacon.createEffect(() {
  ///  print(nums.value); // Outputs: [1, 2, 3]
  /// });
  ///
  /// nums.add(4); // Outputs: [1, 2, 3, 4]
  ///
  /// nums.remove(2); // Outputs: [1, 3, 4]
  /// ```
  static ListBeacon<T> list<T>(List<T> initialValue, {String? debugLabel}) =>
      ListBeacon<T>(initialValue)
        ..setDebugLabel(debugLabel ?? 'ListBeacon<$T>');

  /// Creates an effect based on a provided function. The provided function will be called
  /// whenever one of its dependencies change.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable(15);
  ///
  /// Beacon.createEffect(() {
  ///     if (age.value >= 18) {
  ///       print("You can vote!");
  ///     } else {
  ///        print("You can't vote yet");
  ///     }
  ///  });
  ///
  /// // Outputs: "You can't vote yet"
  ///
  /// age.value = 20; // Outputs: "You can vote!"
  /// ```
  static VoidCallback createEffect(Function fn) {
    return effect(fn);
  }

  /// Executes a batched update which allows multiple updates to be batched into a single update.
  /// This can be used to optimize performance by reducing the number of update notifications.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable<int>(10);
  ///
  /// var callCount = 0;
  ///
  /// age.subscribe((_) => callCount++);
  ///
  /// Beacon.doBatchUpdate(() {
  ///   age.value = 15;
  ///   age.value = 16;
  ///   age.value = 20;
  ///   age.value = 23;
  /// });
  ///
  /// expect(callCount, equals(1)); // There were 4 updates, but only 1 notification
  /// ```
  static void doBatchUpdate(VoidCallback callback) {
    batch(callback);
  }

  /// Runs the function without tracking any changes to the state.
  /// This is useful when you want to run a function that
  /// changes the state, but you don't want to notify listeners of those changes.
  ///
  /// ```dart
  /// final age = Beacon.writable<int>(10);
  /// var callCount = 0;
  /// age.subscribe((_) => callCount++);
  ///
  /// Beacon.createEffect(() {
  ///      age.value;
  ///      Beacon.untracked(() {
  ///        age.value = 15;
  ///      });
  /// });
  ///
  /// expect(callCount, equals(0));
  /// expect(age.value, 15);
  /// ```
  static void untracked(VoidCallback fn) {
    doUntracked(fn);
  }

  /// Creates and manages a family of related `Beacon`s based on a single creation function.
  ///
  /// This class provides a convenient way to handle related
  /// beacons that share the same creation logic but have different arguments.
  ///
  /// ### Type Parameters:
  ///
  /// * `T`: The type of the value emitted by the beacons in the family.
  /// * `Arg`: The type of the argument used to identify individual beacons within the family.
  /// * `BeaconType`: The type of the beacon in the family.
  ///
  /// If `cache` is `true`, created beacons are cached. Default is `false`.
  ///
  /// Example:
  /// ```dart
  ///final apiClientFamily = Beacon.family(
  ///  (String baseUrl) {
  ///    return Beacon.readable(ApiClient(baseUrl));
  ///  },
  ///);
  ///
  /// final githubApiClient = apiClientFamily('https://api.github.com');
  /// final twitterApiClient = apiClientFamily('https://api.twitter.com');
  /// ```
  static BeaconFamily<Arg, BeaconType>
      family<T, Arg, BeaconType extends BaseBeacon<T>>(
    BeaconType Function(Arg) create, {
    bool cache = false,
  }) {
    return BeaconFamily<Arg, BeaconType>(create, shouldCache: cache);
  }
}
