// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

part of '../producer.dart';

/// See: Beacon.rawStream()
class RawStreamBeacon<T> extends ReadableBeacon<T> {
  /// @macro rawStream
  RawStreamBeacon(
    this._compute, {
    this.isLazy = false,
    this.cancelOnError = false,
    this.onError,
    this.onDone,
    super.initialValue,
    super.name,
  }) : assert(
          initialValue != null || null is T || isLazy,
          '''

          Do one of the following:
            1. provide an initialValue
            2. change the type parameter "$T" to "$T?"
            3. set isLazy to true (beacon must be set before it's read from)
          ''',
        ) {
    _start();
  }

  /// Whether the beacon has lazy initialization.
  final bool isLazy;

  /// called when the stream emits an error
  final Function? onError;

  /// called when the stream is done
  final void Function()? onDone;
  final Stream<T> Function() _compute;
  late VoidCallback _effectDispose;

  /// passed to the internal stream subscription
  final bool cancelOnError;

  StreamSubscription<T>? _subscription;

  /// unsubscribes from the internal stream
  void unsubscribe() {
    unawaited(_subscription?.cancel());
  }

  /// Starts listening to the internal stream
  /// if `manualStart` was set to true.
  ///
  /// Calling more than once has no effect
  void _start() {
    if (_subscription != null) return;
    _effectDispose = Beacon.effect(
      () {
        _subscription = _compute().listen(
          _setValue,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );

        return () {
          _subscription!.cancel();
        };
      },
      name: name,
    );
  }

  @override
  void dispose() {
    _effectDispose();
    super.dispose();
  }

  @override
  int get hashCode =>
      _compute.hashCode ^
      cancelOnError.hashCode ^
      onError.hashCode ^
      onDone.hashCode ^
      (isLazy ? 1 : initialValue.hashCode) ^
      name.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RawStreamBeacon && other.hashCode == hashCode;
  }
}
