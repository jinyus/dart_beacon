part of '../producer.dart';

/// A callback keeps track of its dependecies that
/// re-executes whenever one changes.
class Effect with Consumer {
  /// Creates a new [Effect].
  Effect(this._compute, {String? name}) : _name = name {
    _schedule();
  }

  final String? _name;
  @override
  String get name => _name ?? 'Effect';

  final Function _compute;

  Function? _disposeChild;

  void _schedule() {
    _effectQueue.add(this);
    _flushFn();
  }

  @override
  void stale(Status newStatus) {
    if (_status == DIRTY) return;
    if (_status < newStatus) {
      final oldStatus = _status;
      _status = newStatus;

      if (oldStatus == CLEAN) {
        _schedule();
      }
    }
  }

  @override
  void update() {
    final prevConsumer = currentConsumer;
    final prevGets = currentGets;
    final prevGetsIndex = currentGetsIndex;

    currentConsumer = this;
    currentGets = [];
    currentGetsIndex = 0;

    // ignore: avoid_dynamic_calls
    _disposeChild?.call();

    // ignore: avoid_dynamic_calls
    final cleanup = _compute();

    if (cleanup is Function) {
      _disposeChild = cleanup;
    }

    if (currentGets.isNotEmpty) {
      stopWatchingAllAfter(currentGetsIndex);

      if (sources.isNotEmpty && currentGetsIndex > 0) {
        sources.length = currentGetsIndex + currentGets.length;
        for (var i = 0; i < currentGets.length; i++) {
          sources[currentGetsIndex + i] = currentGets[i];
        }
      } else {
        sources = currentGets;
      }

      // Add ourselves to the end of the parent .observers array
      for (var i = currentGetsIndex; i < sources.length; i++) {
        final source = sources[i]!;
        source._observers.add(this);
      }
    } else if (sources.isNotEmpty && currentGetsIndex < sources.length) {
      stopWatchingAllAfter(currentGetsIndex);
      sources.length = currentGetsIndex;
    }

    currentGets = prevGets;
    currentGetsIndex = prevGetsIndex;
    currentConsumer = prevConsumer;

    // We've rerun with the latest values from all of our sources.
    // This means that we no longer need to update until a signal changes
    _status = CLEAN;
  }

  /// Disposes the effect.
  @override
  void dispose() {
    // ignore: avoid_dynamic_calls
    _disposeChild?.call();
    _effectQueue.remove(this);
    // remove ourselves from the .observers list of all sources
    for (final source in sources) {
      source!._removeObserver(this);
    }
    sources.clear();
    _disposeChild = null;
  }
}
