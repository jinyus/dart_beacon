part of 'extensions.dart';

// ignore: public_member_api_docs
extension ReadableBeaconFlutterUtils<T> on ReadableBeacon<T> {
  /// Converts this to a [ValueListenable]
  ValueListenable<T> toListenable() {
    return _toValueNotifier(this);
  }
}
