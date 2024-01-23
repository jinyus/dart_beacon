part of 'base_beacon.dart';

final Set<EffectClosure> _listenersToPingAfterBatchJob = {};

var _batchStack = 0;

bool _isRunningBatchJob() => _batchStack > 0;

void doBatch(void Function() compute) {
  if (_isRunningBatchJob()) {
    compute();
    return;
  }

  _batchStack++;
  try {
    compute();
  } finally {
    _batchStack--;
  }

  // We don't want to notify the current effect
  // since that would cause an infinite loop
  final currentEffect = _Effect.current();

  if (currentEffect != null) {
    if (_listenersToPingAfterBatchJob.contains(currentEffect.func)) {
      throw CircularDependencyException('batch update');
    }
  }

  for (final listener in _listenersToPingAfterBatchJob) {
    listener.run();
  }
  _listenersToPingAfterBatchJob.clear();
}
