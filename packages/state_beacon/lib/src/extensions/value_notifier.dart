import 'package:flutter/widgets.dart';
import 'package:state_beacon/state_beacon.dart';

/// Extensions for [ValueNotifier].
extension ValueNotifierUtils<T> on ValueNotifier<T> {
  /// Converts this to a [ReadableBeacon].
  WritableBeacon<T> toBeacon({BeaconGroup? group, String? name}) {
    final beaconCreator = group ?? Beacon;

    final beacon = beaconCreator.writable<T>(value, name: name);

    var syncing = false;
    void safeWrite(VoidCallback fn) {
      if (syncing) return;
      syncing = true;
      try {
        fn();
      } finally {
        syncing = false;
      }
    }

    void update() => safeWrite(() => beacon.set(value));

    addListener(update);

    beacon
      ..subscribe(
        (v) => safeWrite(() => value = v),
        synchronous: true,
      )
      ..onDispose(() => removeListener(update));

    return beacon;
  }
}
