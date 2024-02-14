// ignore_for_file: comment_references, lines_longer_than_80_chars

part of '../producer.dart';

/// See [Beacon.derived]
class DerivedBeacon<T> extends ReadableBeacon<T> with Consumer {
  /// See [Beacon.derived]
  DerivedBeacon(this._compute, {super.name});

  final T Function() _compute;

  @override
  T peek() {
    if (_status == Status.clean) return super.peek();
    updateIfNecessary();
    return super.peek();
  }

  @override
  T get value {
    currentConsumer?.startWatching(this);
    updateIfNecessary();
    return _value!;
  }

  @override
  void stale(Status newStatus) {
    if (_status.index < newStatus.index) {
      _status = newStatus;

      for (final observer in _observers) {
        if (observer == untrackedConsumer) return;
        observer.markCheck();
      }
    }
  }

  @override
  void update() {
    _previousValue = isEmpty ? null : _value;

    final prevConsumer = currentConsumer;
    final prevGets = currentGets;
    final prevGetsIndex = currentGetsIndex;

    currentConsumer = this;
    currentGets = [];
    currentGetsIndex = 0;

    _value = _compute();
    if (_isEmpty) _initialValue = _value;
    _isEmpty = false;

    // if the sources have changed, update source & observer links
    if (currentGets.isNotEmpty) {
      // remove all old Sources' .observers links to us
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
      // remove all old sources' .observers links to us
      stopWatchingAllAfter(currentGetsIndex);
      sources.length = currentGetsIndex;
    }

    currentGets = prevGets;
    currentGetsIndex = prevGetsIndex;
    currentConsumer = prevConsumer;

    // handles diamond depenendencies if we're the parent of a diamond.
    if (_previousValue != _value && _observers.isNotEmpty) {
      // We've changed value, so mark our children as
      // dirty so they'll reevaluate
      for (final observer in _observers) {
        if (observer == untrackedConsumer) return;
        observer._status = Status.dirty;
      }
    }

    // We've rerun with the latest values from all of our sources.
    // This means that we no longer need to update until a signal changes
    _status = Status.clean;
  }

  @override
  void dispose() {
    for (final source in sources) {
      source!._removeObserver(this);
    }
    sources.length = 0;
    super.dispose();
  }
}
