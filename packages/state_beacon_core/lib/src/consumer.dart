part of 'producer.dart';

/// This class represents anything that can consume a [Producer].
/// This includes [DerivedBeacon] and [Subscription] and [Effect].
mixin Consumer {
  /// The name of the consumer. For debugging purposes.
  String get name;

  /// The list of [Producer]s that this consumer is currently watching.
  List<Producer<dynamic>?> sources = [];
  var _status = Status.dirty;

  /// Handles the status of the consumer when a producer changes.
  void stale(Status newStatus);

  /// Called by a producer when it updates and it's sure that the consumer
  /// is dirty and needs to be updated.
  void markDirty() => stale(Status.dirty);

  /// Called by a producer when it updates and it's unsure if the consumer
  /// is dirty and needs to be updated.
  void markCheck() => stale(Status.check);

  /// Called by [Effect]s and [Subscription]s to tell the consumer to update.
  void updateIfNecessary() {
    if (_status == Status.clean) return;

    if (_status == Status.check) {
      for (final source in sources) {
        if (source is DerivedBeacon) {
          source.updateIfNecessary();

          if (_status == Status.dirty) {
            // No need to check further because we are dirty and must update
            break;
          }
        }
      }
    }

    if (_status == Status.dirty) {
      update();
    }

    _status = Status.clean;
  }

  /// remove all old sources' .observers links to us
  void stopWatchingAllAfter(int index) {
    if (sources.isEmpty) return;

    for (var i = index; i < sources.length; i++) {
      final source = sources[i]!;
      source._observers.remove(this);
      BeaconObserver.instance?.onStopWatch(name, source);
    }
  }

  /// Start watching a new source.
  void startWatching(Producer<dynamic> source) {
    BeaconObserver.instance?.onWatch(name, source);
    // we have to check if currentGets is empty because if it's not
    // then we changed sources in the past so we can't just increment
    // we can only increment when sources are in the same order
    if (currentGets.isEmpty && _producerAtIndex(currentGetsIndex) == source) {
      currentGetsIndex++;
    } else {
      currentGets.add(source);
    }
  }

  Producer<dynamic>? _producerAtIndex(int index) {
    if (index < sources.length) {
      return sources[index];
    }
    return null;
  }

  /// Update the consumer.
  void update();
}
