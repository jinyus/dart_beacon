part of 'extensions.dart';

/// @macro [WritableBeaconFlutterUtils]
extension WritableBeaconFlutterUtils<T> on WritableBeacon<T> {
  /// Converts this to a [ValueNotifier]
  ValueNotifier<T> toValueNotifier() {
    final notifier = _toValueNotifier(this);

    notifier.addListener(() => set(notifier.value));

    return notifier;
  }
}
