part of 'extensions.dart';

extension ReadableBeaconUtils<T> on ReadableBeacon<T> {
  /// Converts a [ReadableBeacon] to [Stream]
  Stream<T> toStream() {
    final controller = StreamController<T>();

    controller.add(value);

    final unsub = subscribe((v) => controller.add(v));

    controller.onCancel = unsub;

    return controller.stream;
  }
}
