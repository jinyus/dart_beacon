import 'package:state_beacon/src/base_beacon.dart';

class BeaconFamily<Arg, BeaconType extends BaseBeacon> {
  final bool shouldCache;
  late final Map<Arg, BeaconType> _cache;
  final BeaconType Function(Arg) _create;

  BeaconFamily(this._create, {this.shouldCache = false}) {
    if (shouldCache) {
      _cache = {};
    }
  }

  /// Retrieves a `Beacon` based on the given argument.
  /// If caching is enabled and a beacon for the provided argument exists in the cache, it is returned.
  /// Otherwise, a new beacon is created using the `create` function.
  BeaconType call(Arg arg) {
    if (!shouldCache) return _create(arg);

    return _cache[arg] ??= _create(arg);
  }

  /// Clears the cache of beacon if caching is enabled.
  void clear() {
    _cache.clear();
  }
}
