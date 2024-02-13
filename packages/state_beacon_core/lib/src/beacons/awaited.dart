part of '../producer.dart';

class _Awaited<T> extends ReadableBeacon<Completer<T>> {
  _Awaited(this._futureBeacon, {super.name})
      : super(initialValue: Completer<T>()) {
    cancel = _futureBeacon.subscribe(
      (v) {
        if (peek().isCompleted) {
          _setValue(Completer<T>());
        }

        if (v case AsyncData<T>(:final value)) {
          super._value.complete(value);
        } else if (v case AsyncError(:final error, :final stackTrace)) {
          super._value.completeError(error, stackTrace);
        }
      },
    );
  }

  late final AsyncBeacon<T> _futureBeacon;

  Future<T> get future => value.future;

  VoidCallback? cancel;

  static _Awaited<T> findOrCreate<T>(AsyncBeacon<T> beacon) {
    final existing = _awaitedBeacons[beacon];

    if (existing != null) {
      return existing as _Awaited<T>;
    }

    final newAwaited = _Awaited(beacon, name: "${beacon.name}'s future");

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

final _awaitedBeacons = <AsyncBeacon<dynamic>, _Awaited<dynamic>>{};
