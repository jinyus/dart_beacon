part of 'creator.dart';

/// An alternative to the global beacon creator ie: `Beacon.writable(0)`; that
/// keeps track of all beacons and effects created so they can be disposed/reset together.
/// This is useful when you're creating multiple beacons in a stateful widget or
/// controller class and want to dispose them together.
///
///eg:
/// ```dart
///  final myGroup = BeaconGroup();
///
///  final name = myGroup.writable('Bob');
///  final age = myGroup.writable(20);
///
///  myGroup.effect(() {
///    print(name.value); // Outputs: Bob
///  });
///
///  age.value = 21;
///  name.value = 'Alice';
///
///  myGroup.resetAll(); // reset beacons but does nothing to the effect
///
///  print(name.value); // Bob
///  print(age.value); // 20
///
///  myGroup.disposeAll();
///
///  print(name.isDisposed); // true
///  print(age.isDisposed); // true
///  // All beacons and effects are disposed
/// ```
class BeaconGroup extends _BeaconCreator {
  final List<ReadableBeacon<dynamic>> _beacons = [];
  final List<VoidCallback> _disposeFns = [];

  /// The number of beacons in this group
  int get beaconCount => _beacons.length;

  @override
  BufferedCountBeacon<T> bufferedCount<T>(int count, {String? name}) {
    final beacon = super.bufferedCount<T>(count, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  BufferedTimeBeacon<T> bufferedTime<T>({
    required Duration duration,
    String? name,
  }) {
    final beacon = super.bufferedTime<T>(duration: duration, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  DebouncedBeacon<T> debounced<T>(
    T initialValue, {
    Duration? duration,
    String? name,
  }) {
    final beacon = super.debounced<T>(
      initialValue,
      duration: duration,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  ReadableBeacon<T> derived<T>(
    T Function() compute, {
    String? name,
  }) {
    final beacon = super.derived<T>(
      compute,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  VoidCallback effect(
    Function fn, {
    bool supportConditional = true,
    String? name,
  }) {
    final callback =
        super.effect(fn, supportConditional: supportConditional, name: name);
    _disposeFns.add(callback);
    return callback;
  }

  @override
  BeaconFamily<Arg, BeaconType>
      family<T, Arg, BeaconType extends ReadableBeacon<T>>(
    BeaconType Function(Arg p1) create, {
    bool cache = true,
  }) {
    final family = super.family<T, Arg, BeaconType>(
      create,
      cache: cache,
    );
    _disposeFns.add(family.clear);
    return family;
  }

  @override
  FilteredBeacon<T> filtered<T>(
    T initialValue, {
    BeaconFilter<T>? filter,
    String? name,
  }) {
    final beacon = super.filtered<T>(initialValue, filter: filter, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  FutureBeacon<T> future<T>(
    Future<T> Function() future, {
    bool manualStart = false,
    bool shouldSleep = true,
    String? name,
  }) {
    final beacon = super.future<T>(
      future,
      manualStart: manualStart,
      shouldSleep: shouldSleep,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  MapBeacon<K, V> hashMap<K, V>(Map<K, V> initialValue, {String? name}) {
    final beacon = super.hashMap<K, V>(initialValue, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  SetBeacon<T> hashSet<T>(Set<T> initialValue, {String? name}) {
    final beacon = super.hashSet<T>(initialValue, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  DebouncedBeacon<T> lazyDebounced<T>({
    Duration? duration,
    T? initialValue,
    String? name,
  }) {
    final beacon = super.lazyDebounced<T>(
      duration: duration,
      initialValue: initialValue,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  FilteredBeacon<T> lazyFiltered<T>({
    T? initialValue,
    BeaconFilter<T>? filter,
    bool lazyBypass = true,
    String? name,
  }) {
    final beacon = super.lazyFiltered<T>(
      initialValue: initialValue,
      filter: filter,
      lazyBypass: lazyBypass,
      name: name,
    );

    _beacons.add(beacon);
    return beacon;
  }

  @override
  ThrottledBeacon<T> lazyThrottled<T>({
    Duration? duration,
    T? initialValue,
    bool dropBlocked = true,
    String? name,
  }) {
    final beacon = super.lazyThrottled<T>(
      duration: duration,
      initialValue: initialValue,
      dropBlocked: dropBlocked,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  TimestampBeacon<T> lazyTimestamped<T>({T? initialValue, String? name}) {
    final beacon = super.lazyTimestamped<T>(
      initialValue: initialValue,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  UndoRedoBeacon<T> lazyUndoRedo<T>({
    T? initialValue,
    int historyLimit = 10,
    String? name,
  }) {
    final beacon = super.lazyUndoRedo<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
      name: name,
    );

    _beacons.add(beacon);
    return beacon;
  }

  @override
  WritableBeacon<T> lazyWritable<T>({T? initialValue, String? name}) {
    final beacon = super.lazyWritable<T>(
      initialValue: initialValue,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  ListBeacon<T> list<T>(List<T> initialValue, {String? name}) {
    final beacon = super.list<T>(initialValue, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  ReadableBeacon<T> readable<T>(T initialValue, {String? name}) {
    final beacon = super.readable<T>(initialValue, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  StreamBeacon<T> stream<T>(
    Stream<T> Function() stream, {
    bool cancelOnError = false,
    bool manualStart = false,
    bool shouldSleep = true,
    String? name,
  }) {
    final beacon = super.stream<T>(
      stream,
      cancelOnError: cancelOnError,
      manualStart: manualStart,
      shouldSleep: shouldSleep,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  RawStreamBeacon<T> streamRaw<T>(
    Stream<T> Function() stream, {
    bool cancelOnError = false,
    bool isLazy = false,
    bool shouldSleep = true,
    Function? onError,
    VoidCallback? onDone,
    T? initialValue,
    String? name,
  }) {
    final beacon = super.streamRaw<T>(
      stream,
      cancelOnError: cancelOnError,
      onError: onError,
      onDone: onDone,
      initialValue: initialValue,
      shouldSleep: shouldSleep,
      isLazy: isLazy,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  ThrottledBeacon<T> throttled<T>(
    T initialValue, {
    Duration? duration,
    bool dropBlocked = true,
    String? name,
  }) {
    final beacon = super.throttled<T>(
      initialValue,
      duration: duration,
      dropBlocked: dropBlocked,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  TimestampBeacon<T> timestamped<T>(T initialValue, {String? name}) {
    final beacon = super.timestamped<T>(initialValue, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  @override
  UndoRedoBeacon<T> undoRedo<T>(
    T initialValue, {
    int historyLimit = 10,
    String? name,
  }) {
    final beacon = super.undoRedo<T>(
      initialValue,
      historyLimit: historyLimit,
      name: name,
    );
    _beacons.add(beacon);
    return beacon;
  }

  @override
  WritableBeacon<T> writable<T>(T initialValue, {String? name}) {
    final beacon = super.writable<T>(initialValue, name: name);
    _beacons.add(beacon);
    return beacon;
  }

  /// Dispose all beacons and effects in this group
  void disposeAll() {
    for (final fn in _disposeFns) {
      fn();
    }

    for (final beacon in _beacons) {
      beacon.dispose();
    }

    _disposeFns.clear();
    _beacons.clear();
  }

  /// Reset all writable beacons in this group
  void resetAll() {
    for (final beacon in _beacons) {
      if (beacon is WritableBeacon) {
        beacon.reset();
      } else if (beacon is BufferedBaseBeacon) {
        beacon.reset();
      } else if (beacon is FutureBeacon) {
        beacon.reset();
      }
    }
  }
}
