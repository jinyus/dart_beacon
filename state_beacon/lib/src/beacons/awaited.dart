part of '../base_beacon.dart';

class Awaited<T> extends ReadableBeacon<Completer<T>> {
  late final AsyncBeacon<T> _futureBeacon;

  Future<T> get future => value.future;

  VoidCallback? cancel;

  Awaited(this._futureBeacon, {super.debugLabel})
      : super(initialValue: Completer<T>()) {
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

  static Awaited<T> findOrCreate<T>(AsyncBeacon<T> beacon) {
    final existing = _awaitedBeacons[beacon];

    if (existing != null) {
      return existing as Awaited<T>;
    }

    final newAwaited = Awaited(beacon);

    _awaitedBeacons[beacon] = newAwaited;

    return newAwaited;
  }

  static void remove<T>(AsyncBeacon<T> beacon) {
    final awaitedBeacon = _awaitedBeacons.remove(beacon);

    awaitedBeacon?.dispose();
  }

  @override
  void dispose() {
    cancel?.call();
    super.dispose();
  }
}

final _awaitedBeacons = <AsyncBeacon<dynamic>, Awaited<dynamic>>{};
