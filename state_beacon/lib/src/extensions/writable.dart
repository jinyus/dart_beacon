part of 'extensions.dart';

extension BoolUtils on WritableBeacon<bool> {
  void toggle() {
    value = !peek();
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
