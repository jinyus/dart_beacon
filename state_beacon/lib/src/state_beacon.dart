// ignore_for_file: invalid_use_of_protected_member

import 'async_value.dart';
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
  static WritableBeacon<T> writable<T>(T initialValue) =>
      WritableBeacon<T>(initialValue);

  /// Like `writable`, but the initial value is lazily initialized.
  static WritableBeacon<T> lazyWritable<T>([T? initialValue]) =>
      WritableBeacon<T>(initialValue);

  /// Creates a `ReadableBeacon` with an initial value.
  /// This beacon allows only reading the value.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.readable(15);
  /// print(myBeacon.value); // Outputs: 15
  /// ```
  static ReadableBeacon<T> readable<T>(T initialValue) =>
      ReadableBeacon<T>(initialValue);

  /// Returns a `ReadableBeacon` and a function that allows writing to the beacon.
  /// This is useful for creating a beacon that's readable by the public,
  /// but writable only by the owner.
  ///
  /// Example:
  /// ```dart
  /// var (count,setCount) = Beacon.scopedWritable(15);
  /// ```
  static (ReadableBeacon<T>, void Function(T)) scopedWritable<T>(
      T initialValue) {
    final beacon = WritableBeacon<T>(initialValue);
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
  static DebouncedBeacon<T> debounced<T>(T initialValue,
          {required Duration duration}) =>
      DebouncedBeacon<T>(initialValue: initialValue, duration: duration);

  /// Like `debounced`, but the initial value is lazily initialized.
  static DebouncedBeacon<T> lazyDebounced<T>({
    T? initialValue,
    required Duration duration,
  }) =>
      DebouncedBeacon<T>(initialValue: initialValue, duration: duration);

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
  }) =>
      ThrottledBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        dropBlocked: dropBlocked,
      );

  /// Like `throttled`, but the initial value is lazily initialized.
  static ThrottledBeacon<T> lazyThrottled<T>({
    T? initialValue,
    required Duration duration,
    bool dropBlocked = true,
  }) =>
      ThrottledBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        dropBlocked: dropBlocked,
      );

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
    T initialValue, [
    BeaconFilter<T>? filter,
  ]) {
    return FilteredBeacon<T>(initialValue: initialValue, filter: filter);
  }

  /// Like `filtered`, but the initial value is lazily initialized.
  /// The first will not be filtered if the `initialValue` is null.
  static FilteredBeacon<T> lazyFiltered<T>({
    T? initialValue,
    BeaconFilter<T>? filter,
  }) {
    return FilteredBeacon<T>(initialValue: initialValue, filter: filter);
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
  static BufferedCountBeacon<T> bufferedCount<T>(int count) =>
      BufferedCountBeacon<T>(countThreshold: count);

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
  static BufferedTimeBeacon<T> bufferedTime<T>({required Duration duration}) =>
      BufferedTimeBeacon<T>(duration: duration);

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
  }) {
    return UndoRedoBeacon<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
    );
  }

  /// Like `undoRedo`, but the initial value is lazily initialized.
  static UndoRedoBeacon<T> lazyUndoRedo<T>({
    T? initialValue,
    int historyLimit = 10,
  }) {
    return UndoRedoBeacon<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
    );
  }

  /// Creates a `TimestampBeacon` with an initial value.
  /// This beacon attaches a timestamp to each value update.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.timestamped(10);
  /// print(myBeacon.value); // Outputs: (value: 10, timestamp: DateTime.now())
  /// ```
  static TimestampBeacon<T> timestamped<T>(T initialValue) =>
      TimestampBeacon<T>(initialValue);

  /// Like `timestamped`, but the initial value is lazily initialized.
  static TimestampBeacon<T> lazyTimestamped<T>([T? initialValue]) =>
      TimestampBeacon<T>(initialValue);

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
  }) {
    return StreamBeacon<T>(
      stream,
      cancelOnError: cancelOnError,
    );
  }

  /// Like `stream`, but it doesn't wrap the value in an `AsyncValue`.
  static RawStreamBeacon<T> streamRaw<T>(
    Stream<T> stream, {
    bool cancelOnError = false,
    Function? onError,
    Function? onDone,
    T? initialValue,
  }) {
    return RawStreamBeacon<T>(
      stream,
      cancelOnError: cancelOnError,
      onError: onError,
      onDone: onDone,
      initialValue: initialValue,
    );
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
  }) {
    return DefaultFutureBeacon<T>(
      future,
      manualStart: manualStart,
      cancelRunning: cancelRunning,
    );
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
  }) {
    final beacon = DerivedBeacon<T>(manualStart: manualStart);

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
    Future<T> Function() compute, {
    bool manualStart = false,
    bool cancelRunning = true,
  }) {
    final beacon = DerivedFutureBeacon<T>(
      manualStart: manualStart,
      cancelRunning: cancelRunning,
    );

    final unsub = effect(() async {
      // beacon is manually triggered if in idle state
      if (beacon.status.value == DerivedFutureStatus.idle) return;

      // start loading and get the execution ID
      final exeID = beacon.$startLoading();
      try {
        final result = await compute();
        beacon.$setAsyncValue(exeID, AsyncData(result));
      } catch (e, s) {
        beacon.$setAsyncValue(exeID, AsyncError(e, s));
      }
    });

    beacon.$setInternalEffectUnsubscriber(unsub);

    return beacon;
  }

  /// Creates a `ListBeacon` with an initial list value.
  /// This beacon manages a list of items, allowing for reactive updates and manipulations of the list.
  ///
  /// The `ListBeacon` provides methods to add, remove, and update items in the list in a way that can be
  /// observed by listeners. This is useful for managing collections of data that need to be dynamically
  /// updated and tracked in an application.
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
  static ListBeacon<T> list<T>([List<T>? initialValue]) =>
      ListBeacon<T>(initialValue ?? []);

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
}
