part of '../base_beacon.dart';

typedef AsyncBeacon<T> = ReadableBeacon<AsyncValue<T>>;

class Awaited<T, S extends AsyncBeacon<T>>
    extends ReadableBeacon<Completer<T>> {
  late final S _futureBeacon;

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

  static Awaited<T, S>? find<T, S extends AsyncBeacon<T>>(S beacon) {
    final existing = _awaitedBeacons[beacon];
    if (existing != null) {
      return existing as Awaited<T, S>;
    }
    return null;
  }

  static void put<T, S extends AsyncBeacon<T>>(
      S beacon, Awaited<T, S> awaited) {
    _awaitedBeacons[beacon] = awaited;
  }
}

final _awaitedBeacons = <AsyncBeacon, Awaited>{};
