part of '../producer.dart';

/// This returns a beacon that is created using the provided `create` function.
/// The beacon is cached and returned if the same argument is provided again.
class BeaconFamily<Arg, BeaconType extends ReadableBeacon<dynamic>> {
  /// @macro [BeaconFamily]
  BeaconFamily(this._create, {this.shouldCache = true}) {
    if (shouldCache) {
      _cache = {};
    }
  }

  /// Whether or not to cache the created beacons.
  final bool shouldCache;

  late final Map<Arg, BeaconType> _cache;
  final BeaconType Function(Arg) _create;

  /// Retrieves a `Beacon` based on the given argument.
  /// If caching is enabled and a beacon for the provided argument
  /// exists in the cache, it is returned.
  /// Otherwise, a new beacon is created using the `create` function.
  BeaconType call(Arg arg) {
    if (!shouldCache) return _create(arg);

    return _cache[arg] ??= _create(arg)
      ..onDispose(() {
        _cache.remove(arg);
      });
  }

  /// Clears the cache of beacon if caching is enabled.
  /// Beacons are disposed before thy are removed
  void clear() {
    if (!shouldCache) return;

    for (final beacon in _cache.values.toList()) {
      beacon.dispose();
    }

    _cache.clear();
  }
}
