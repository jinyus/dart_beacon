part of 'base_beacon.dart';

final _effectStack = <_Effect>[];

class _Effect {
  final Set<Listeners> dependencies;
  late final EffectClosure func;
  final bool _supportConditional;

  _Effect(this._supportConditional) : dependencies = <Listeners>{};

  VoidCallback execute(Function fn) {
    func = EffectClosure(() {
      if (_supportConditional) _cleanup(this);
      _effectStack.add(this);
      try {
        fn();
      } finally {
        _effectStack.removeLast();
      }
    });

    func.run();
    return () => _cleanup(this);
  }

  static _Effect? current() {
    return _effectStack.lastOrNull;
  }

  static void _cleanup(_Effect runningEffect) {
    for (final dep in runningEffect.dependencies) {
      dep.remove(runningEffect.func);
    }

    runningEffect.dependencies.clear();
  }
}

VoidCallback effect(Function fn, {bool supportConditional = true}) {
  final effect = _Effect(supportConditional);
  return effect.execute(fn);
}

void _subscribe(_Effect runningEffect, Listeners subscriptions) {
  subscriptions.add(runningEffect.func);
  runningEffect.dependencies.add(subscriptions);
}
