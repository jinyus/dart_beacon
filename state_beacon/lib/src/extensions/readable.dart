part of 'extensions.dart';

extension ReadableBeaconUtils<T> on ReadableBeacon<T> {
  /// Converts a [ReadableBeacon] to [Stream]
  Stream<T> toStream({
    FutureOr<void> Function()? onCancel,
  }) {
    final controller = StreamController<T>();

    controller.add(value);

    final unsub = subscribe((v) => controller.add(v));

    void cancel() {
      unsub();
      controller.close();
      onCancel?.call();
    }

    controller.onCancel = cancel;

    onDispose(cancel);

    return controller.stream.asBroadcastStream();
  }
}
