// ignore_for_file: public_member_api_docs, avoid_dynamic_calls

part of 'base_beacon.dart';

// final _effectStack = <_Effect>[];

_Effect? _currentEffect;

class _Effect {
  _Effect(this._supportConditional, {String? name}) {
    _watchedBeacons = {};
    _currentDeps = {};
    _name = name ?? 'Effect(unlabeled)';
  }

  late final Set<BaseBeacon<dynamic>> _watchedBeacons;
  late final EffectClosure func;
  late final Set<BaseBeacon<dynamic>> _currentDeps;
  late final String _name;
  final bool _supportConditional;
  Function? _disposeChild;
  _Effect? _parentEffect;

  VoidCallback execute(Function fn) {
    void cleanUpAndRun() {
      _disposeChild?.call();
      final cleanup = fn();
      if (cleanup is Function) _disposeChild = cleanup;
    }

    // if we dont support conditional, never look for dependencies
    // in subsequent runs
    func = EffectClosure(
      _supportConditional
          ? () {
              _parentEffect = _currentEffect;
              _currentEffect = this;
              try {
                _currentDeps.clear();
                cleanUpAndRun();
              } finally {
                _currentEffect = _parentEffect;
                _parentEffect = null;
                final toRemove = _watchedBeacons.difference(_currentDeps);
                if (toRemove.isNotEmpty) _remove(toRemove);
                _currentDeps.clear();
              }
            }
          : cleanUpAndRun,
    );

    // first run to discover dependencies
    _parentEffect = _currentEffect;
    _currentEffect = this;
    try {
      cleanUpAndRun();
    } finally {
      _currentEffect = _parentEffect;
      _parentEffect = null;
    }

    // dispose function
    return () {
      _remove(_watchedBeacons, disposing: true);
      _disposeChild?.call();
    };
  }

  void _remove(
    Iterable<BaseBeacon<dynamic>> staleBeacons, {
    bool disposing = false,
  }) {
    for (final beacon in staleBeacons) {
      // remove self from beacon's listeners
      beacon._listeners.remove(func);
      BeaconObserver.instance?.onStopWatch(_name, beacon);
    }

    // remove from local tracker
    if (disposing) {
      _watchedBeacons.clear();
      _currentDeps.clear();
    } else {
      _watchedBeacons.removeAll(staleBeacons);
    }
  }

  void _startWatching(BaseBeacon<dynamic> beacon) {
    if (_watchedBeacons.contains(beacon)) {
      if (_supportConditional) _currentDeps.add(beacon);
      return;
    }

    _watchedBeacons.add(beacon);
    beacon._listeners.add(func);

    BeaconObserver.instance?.onWatch(_name, beacon);

    if (_supportConditional) _currentDeps.add(beacon);
  }
}

VoidCallback doEffect(
  Function fn, {
  bool supportConditional = true,
  String? name,
}) {
  final effect = _Effect(supportConditional, name: name);
  return effect.execute(fn);
}
