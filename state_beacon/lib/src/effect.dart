part of 'base_beacon.dart';

final _effectStack = <_Effect>[];

class _Effect {
  late final Set<Listeners> dependencies;

  late final Set<BaseBeacon<dynamic>> _beacons;
  late final EffectClosure func;
  late final Set<BaseBeacon<dynamic>> _newDeps;
  final bool _supportConditional;

  _Effect(this._supportConditional, {required Function fn}) {
    dependencies = {};
    _beacons = {};
    _newDeps = {};

    // if we dont support conditional, never look for dependencies
    // in subsequent runs
    func = EffectClosure(_supportConditional
        ? () {
            _effectStack.add(this);
            try {
              fn();
            } finally {
              _effectStack.removeLast();
              final toRemove = _beacons.difference(_newDeps);
              _remove(toRemove);
            }
          }
        : fn);
  }

  VoidCallback execute(Function fn) {
    // first run to discover dependencies
    _effectStack.add(this);
    try {
      fn();
    } finally {
      _effectStack.removeLast();
    }

    return () => _remove(_beacons, disposing: true);
  }

  void _remove(
    Iterable<BaseBeacon<dynamic>> staleBeacons, {
    bool disposing = false,
  }) {
    for (final beacon in staleBeacons) {
      // remove self from beacon's listeners
      beacon._listeners.remove(func);
    }

    // remove from local tracker
    if (disposing) {
      _beacons.clear();
    } else {
      _beacons.removeAll(staleBeacons);
    }

    _newDeps.clear();
  }

  void _startWatching(BaseBeacon<dynamic> beacon) {
    if (_beacons.contains(beacon)) {
      if (_supportConditional) _newDeps.add(beacon);
      return;
    }

    _beacons.add(beacon);
    beacon._listeners.add(func);

    if (_supportConditional) _newDeps.add(beacon);
    ;
  }

  static _Effect? current() {
    return _effectStack.lastOrNull;
  }
}

VoidCallback effect(Function fn, {bool supportConditional = true}) {
  final effect = _Effect(supportConditional, fn: fn);
  return effect.execute(fn);
}
