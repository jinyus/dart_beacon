part of 'extensions.dart';

/// @macro [WritableBeaconFlutterUtils]
extension WritableBeaconFlutterUtils<T> on WritableBeacon<T> {
  /// Converts this to a [ValueNotifier]
  ValueNotifier<T> toValueNotifier() {
    final notifier = ValueNotifierBeacon(value);

    final unsub = subscribe(notifier.set);

    notifier
      ..addListener(() => value = notifier.value)
      ..addDisposeCallback(unsub);

    onDispose(notifier.dispose);

    return notifier;
  }
}
