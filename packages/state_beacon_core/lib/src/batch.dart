part of 'base_beacon.dart';

final Set<EffectClosure> _listenersToPingAfterBatchJob = {};

var _batchStack = 0;

bool _isRunningBatchJob() => _batchStack > 0;

// ignore: public_member_api_docs
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
  final currentEffect = _currentEffect;

  if (currentEffect != null) {
    if (_listenersToPingAfterBatchJob.contains(currentEffect.func)) {
      throw CircularDependencyException(
        currentEffect._name,
        'a beacon inside a batch job',
      );
    }
  }

  for (final listener in _listenersToPingAfterBatchJob) {
    // ignore: avoid_dynamic_calls
    listener.run();
  }
  _listenersToPingAfterBatchJob.clear();
}
