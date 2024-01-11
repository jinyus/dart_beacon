part of 'base_beacon.dart';

final _effectStack = <_Effect>[];

class _Effect {
  late final Set<BaseBeacon<dynamic>> _watchedBeacons;
  late final EffectClosure func;
  late final Set<BaseBeacon<dynamic>> _currentDeps;
  late final String _debugLabel;
  final bool _supportConditional;
  Function? _disposeChild;

  _Effect(this._supportConditional,
      {required Function fn, String? debugLabel}) {
    _watchedBeacons = {};
    _currentDeps = {};
    _debugLabel = debugLabel ?? 'Effect(unlabeled)';
  }

  VoidCallback execute(Function fn) {
    cleanUpAndRun() {
      _disposeChild?.call();
      final cleanup = fn();
      if (cleanup is Function) _disposeChild = cleanup;
    }

    // if we dont support conditional, never look for dependencies
    // in subsequent runs
    func = EffectClosure(_supportConditional
        ? () {
            _effectStack.add(this);
            try {
              cleanUpAndRun();
            } finally {
              _effectStack.removeLast();
              final toRemove = _watchedBeacons.difference(_currentDeps);
              if (toRemove.isNotEmpty) _remove(toRemove);
              _currentDeps.clear();
            }
          }
        : cleanUpAndRun);

    // first run to discover dependencies
    _effectStack.add(this);
    try {
      cleanUpAndRun();
    } finally {
      _effectStack.removeLast();
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
      BeaconObserver.instance?.onStopWatch(_debugLabel, beacon);
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

    BeaconObserver.instance?.onWatch(_debugLabel, beacon);

    if (_supportConditional) _currentDeps.add(beacon);
  }

  static _Effect? current() {
    return _effectStack.lastOrNull;
  }
}

VoidCallback effect(
  Function fn, {
  bool supportConditional = true,
  String? debugLabel,
}) {
  final effect = _Effect(supportConditional, fn: fn, debugLabel: debugLabel);
  return effect.execute(fn);
}
