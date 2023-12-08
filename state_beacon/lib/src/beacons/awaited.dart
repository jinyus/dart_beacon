part of '../base_beacon.dart';

class Awaited<T> extends ReadableBeacon<Completer<T>> {
  late final FutureBeacon<T> _futureBeacon;

  Future<T> get future => value.future;

  VoidCallback? cancel;

  Awaited(this._futureBeacon, {String? debugName}) : super(Completer<T>()) {
    cancel = _futureBeacon.subscribe((v) {
      if (peek().isCompleted) {
        _setValue(Completer<T>());
      }
      if (v case AsyncData<T>(:final value)) {
        super._value.complete(value);
      } else if (v case AsyncError(:final error, :final stackTrace)) {
        super._value.completeError(error, stackTrace);
      }
    }, startNow: true);
  }

  static Awaited<T>? find<T>(FutureBeacon<T> beacon) {
    final existing = _awaitedBeacons[beacon];
    if (existing != null) {
      return existing as Awaited<T>;
    }
    return null;
  }

  static void put<T>(FutureBeacon<T> beacon, Awaited<T> awaited) {
    _awaitedBeacons[beacon] = awaited;
  }
}

final _awaitedBeacons = <FutureBeacon, Awaited>{};
