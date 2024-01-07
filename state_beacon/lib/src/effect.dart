part of 'base_beacon.dart';

final _effectStack = <_Effect>[];
var _batchStack = 0;

bool _isRunningBatchJob() => _batchStack > 0;

final Set<EffectClosure> _listenersToPingAfterBatchJob = {};

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

void batch(void Function() compute) {
  _batchStack++;
  compute();
  _batchStack--;

  if (_isRunningBatchJob()) {
    return;
  }

  // We don't want to notify the current effect
  // since that would cause an infinite loop
  final currentEffect = _Effect.current();

  if (currentEffect != null) {
    if (_listenersToPingAfterBatchJob.contains(currentEffect.func)) {
      throw CircularDependencyException();
    }
  }

  for (final listener in _listenersToPingAfterBatchJob) {
    listener.run();
  }
  _listenersToPingAfterBatchJob.clear();
}

void _subscribe(_Effect runningEffect, Listeners subscriptions) {
  subscriptions.add(runningEffect.func);
  runningEffect.dependencies.add(subscriptions);
}
