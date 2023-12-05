import 'dart:async';

import 'package:flutter/foundation.dart';

import 'base_beacon.dart';

extension BoolUtils on WritableBeacon<bool> {
  void toggle() {
    value = !peek();
  }
}

extension ListUtils<T> on List<T> {
  /// Converts a list to [ListBeacon].
  ListBeacon<T> toBeacon() {
    return ListBeacon<T>(this);
  }
}

extension StreamUtils<T> on Stream<T> {
  /// Converts a stream to [StreamBeacon].
  StreamBeacon<T> toBeacon({bool cancelOnError = false}) {
    return StreamBeacon<T>(this, cancelOnError: cancelOnError);
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
