import 'async_value.dart';
import 'base_beacon.dart';

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
    return (beacon, (value) => beacon.value = value);
  }

  /// Creates a `LazyBeacon` with an optional initial value.
  /// The value must be initialized before it's first accessed.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.lazy<int>();
  /// // Value is initialized when it's first accessed
  /// ```
  static LazyBeacon<T> lazy<T>([T? initialValue]) =>
      LazyBeacon<T>(initialValue);

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
      DebouncedBeacon<T>(initialValue, duration: duration);

  /// Creates a `ThrottledBeacon` with an initial value and a throttle duration.
  /// This beacon limits the rate of updates to its value based on the duration.
  /// Updates that occur faster than the throttle duration are ignored.
  ///
  /// Example:
  /// ```dart
  /// var age = Beacon.throttled(10, duration: Duration(seconds: 1));
  /// age.value = 20; // Update is throttled
  /// print(age.value); // Outputs: 10
  /// await Future.delayed(Duration(seconds: 1));
  /// print(age.value); // Outputs: 10 because the update was ignored
  /// ```
  static ThrottledBeacon<T> throttled<T>(T initialValue,
          {required Duration duration}) =>
      ThrottledBeacon<T>(initialValue, duration: duration);

  /// Creates a `FilteredBeacon` with an initial value and a filter function.
  /// This beacon updates its value only if it passes the filter criteria.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.filtered(10, (value) => value > 5);
  /// myBeacon.value = 4; // Does not update value
  /// ```
  static FilteredBeacon<T> filtered<T>(T initialValue, BeaconFilter filter) =>
      FilteredBeacon<T>(initialValue, filter: filter);

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

  /// Creates a `StreamBeacon` from a given stream.
  /// This beacon updates its value based on the stream's emitted values.
  ///
  /// Example:
  /// ```dart
  /// var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// var myBeacon = Beacon.stream(myStream);
  /// myBeacon.subscribe((value) {
  ///   print(value); // Outputs the stream's emitted values
  /// });
  /// ```
  static StreamBeacon<T> stream<T>(Stream<T> stream) => StreamBeacon<T>(stream);

  /// Creates a `FutureBeacon` that initializes its value based on a future.
  /// The beacon can optionally depend on another `ReadableBeacon`.
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
  static FutureBeacon<T> future<T>(Future<T> Function() future) {
    return FutureBeacon<T>(future);
  }

  /// Creates a `DerivedBeacon` whose value is derived from a computation function.
  /// This beacon will recompute its value everytime one of it's dependencies change.
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
  static DerivedBeacon<T> derived<T>(T Function() compute) {
    final beacon = DerivedBeacon<T>();

    final unsub = effect(() {
      beacon.forceSetValue(compute());
    });

    beacon.$setInternalEffectUnsubscriber(unsub);

    return beacon;
  }

  /// Creates a `DerivedBeacon` whose value is derived from an asynchronous computation.
  /// This beacon will recompute its value every time one of its dependencies change.
  /// The result is wrapped in an `AsyncValue`, which can be in one of three states: loading, data, or error.
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
  static DerivedBeacon<AsyncValue<T>> derivedFuture<T>(
      Future<T> Function() compute) {
    final beacon = DerivedFutureBeacon<T>();

    final unsub = effect(() async {
      // start loading and get the execution ID
      final exeID = beacon.startLoading();

      try {
        final result = await compute();
        beacon.setAsyncValue(exeID, AsyncData(result));
      } catch (e, s) {
        beacon.setAsyncValue(exeID, AsyncError(e, s));
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
  /// });
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
