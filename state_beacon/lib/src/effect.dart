part of 'base_beacon.dart';

final _effectStack = <_Effect>[];
final _batchStack = <Null>[];

bool _isRunningBatchJob() => _batchStack.isNotEmpty;

final Listerners _listenersToPingAfterBatchJob = {};

class _Effect {
  final Set<Listerners> dependencies;
  late final EffectClosure func;

  _Effect() : dependencies = <Listerners>{};

  VoidCallback execute(Function fn) {
    func = EffectClosure(() {
      _cleanup(this);
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

VoidCallback effect(Function fn) {
  final effect = _Effect();
  return effect.execute(fn);
}

void batch(void Function() compute) {
  _batchStack.add(null);
  compute();
  _batchStack.removeLast();

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

void _subscribe(_Effect runningEffect, Listerners subscriptions) {
  subscriptions.add(runningEffect.func);
  runningEffect.dependencies.add(subscriptions);
}
