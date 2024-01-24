part of 'extensions.dart';

// ignore: public_member_api_docs
extension ReadableBeaconFlutterUtils<T> on ReadableBeacon<T> {
  /// Converts this to a [ValueListenable]
  ValueListenable<T> toListenable() {
    final notifier = ValueNotifierBeacon(value);

    final unsub = subscribe(notifier.set);

    notifier.addDisposeCallback(unsub);

    onDispose(notifier.dispose);

    return notifier;
  }
}
