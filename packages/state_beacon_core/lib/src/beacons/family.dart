part of '../producer.dart';

/// This returns a beacon that is created using the provided `create` function.
/// The beacon is cached and returned if the same argument is provided again.
class BeaconFamily<Arg, BeaconType extends ReadableBeacon<dynamic>> {
  /// @macro [BeaconFamily]
  BeaconFamily(this._create, {this.shouldCache = true});

  /// Whether or not to cache the created beacons.
  final bool shouldCache;

  /// The cache of beacons.This is a MapBeacon that
  /// will notify its listeners when it's modified.
  late final cache = Beacon.hashMap<Arg, BeaconType>({});

  final BeaconType Function(Arg) _create;

  var _clearing = false;

  /// Retrieves a `Beacon` based on the given argument.
  /// If caching is enabled and a beacon for the provided argument
  /// exists in the cache, it is returned.
  /// Otherwise, a new beacon is created using the `create` function.
  BeaconType call(Arg arg) {
    if (!shouldCache) return _create(arg);

    return cache[arg] ??= _create(arg)
      ..onDispose(() {
        if (_clearing) return;
        cache.remove(arg);
      });
  }

  /// Clears the cache of beacon if caching is enabled.
  /// Beacons are disposed before they are removed
  void clear() {
    if (!shouldCache) return;

    _clearing = true;

    for (final beacon in cache.peek().values.toList()) {
      beacon.dispose();
    }

    _clearing = false;

    cache.clear();
  }
}
