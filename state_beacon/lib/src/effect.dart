part of 'base_beacon.dart';

final _effectStack = <_Effect>[];

class _Effect {
  late final Set<BaseBeacon<dynamic>> _watchedBeacon;
  late final EffectClosure func;
  late final Set<BaseBeacon<dynamic>> _newDeps;
  final bool _supportConditional;

  _Effect(this._supportConditional, {required Function fn}) {
    _watchedBeacon = {};
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
              final toRemove = _watchedBeacon.difference(_newDeps);
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

    return () => _remove(_watchedBeacon, disposing: true);
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
      _watchedBeacon.clear();
    } else {
      _watchedBeacon.removeAll(staleBeacons);
    }

    _newDeps.clear();
  }

  void _startWatching(BaseBeacon<dynamic> beacon) {
    if (_watchedBeacon.contains(beacon)) {
      if (_supportConditional) _newDeps.add(beacon);
      return;
    }

    _watchedBeacon.add(beacon);
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
