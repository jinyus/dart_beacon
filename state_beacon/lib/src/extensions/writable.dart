part of 'extensions.dart';

extension BoolUtils on WritableBeacon<bool> {
  void toggle() {
    value = !peek();
  }
}

extension IntUtils<T extends num> on WritableBeacon<T> {
  void increment() {
    value = value + 1 as T;
  }

  void decrement() {
    value = value - 1 as T;
  }
}

extension WritableBeaconUtils<T> on WritableBeacon<T> {
  /// Converts a [WritableBeacon] to [ValueNotifier]
  ValueNotifier<T> toValueNotifier() {
    final notifier = ValueNotifierBeacon(value);

    final unsub = subscribe(notifier.set);

    notifier.addListener(() => value = notifier.value);

    notifier.addDisposeCallback(unsub);

    return notifier;
  }
}
