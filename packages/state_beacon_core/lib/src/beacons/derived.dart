// ignore_for_file: comment_references, lines_longer_than_80_chars

part of '../producer.dart';

/// See [Beacon.derived]
class DerivedBeacon<T> extends ReadableBeacon<T> with Consumer {
  /// See [Beacon.derived]
  DerivedBeacon(this._compute, {super.name});

  final T Function() _compute;

  @override
  bool get isDerived => true;

  @override
  T peek() {
    updateIfNecessary();
    return super.peek();
  }

  @override
  T get value {
    currentConsumer?.startWatching(this);
    updateIfNecessary();
    return _value;
  }

  @override
  void stale(Status newStatus) {
    if (_status < newStatus) {
      _status = newStatus;

      for (var i = 0; i < _observers.length; i++) {
        _observers[i].markCheck();
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

    final didUpdate = _previousValue != _value;

    // handles diamond depenendencies if we're the parent of a diamond.
    if (didUpdate && _observers.isNotEmpty) {
      // We've changed value, so mark our children as
      // dirty so they'll reevaluate
      for (var i = 0; i < _observers.length; i++) {
        _observers[i]._status = DIRTY;
      }
    }

    // We've rerun with the latest values from all of our sources.
    // This means that we no longer need to update until a signal changes
    _status = CLEAN;

    assert(() {
      if (didUpdate) {
        BeaconObserver.instance?.onUpdate(this);
      }
      return true;
    }());
  }

  @override
  void dispose() {
    for (final source in sources) {
      source!._removeObserver(this);
    }
    sources.clear();
    super.dispose();
  }
}
