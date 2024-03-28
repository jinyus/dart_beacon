import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should group beacons', () {
    final group = BeaconGroup();

    var created = 0;
    final cancel = group.onCreate((_) => created++);

    final readable = group.readable(0);
    final writable = group.writable(0);
    final lazyWritable = group.lazyWritable<int>();
    final bufferedCount = group.bufferedCount<int>(1);
    final bufferedTime = group.bufferedTime<int>(duration: k10ms);
    final debounced = group.debounced<int>(0, duration: k10ms);
    final lazyDebounced = group.lazyDebounced<int>(duration: k10ms);
    final derived = group.derived<int>(() => writable() + 1);
    final filtered = group.filtered(0);
    final lazyFiltered = group.lazyFiltered<int>();
    final throttled = group.throttled<int>(0, duration: k10ms);
    final lazyThrottled = group.lazyThrottled<int>(duration: k10ms);
    final timestamp = group.timestamped<int>(0);
    final lazyTimestamp = group.lazyTimestamped<int>();
    final undoRedo = group.undoRedo<int>(0);
    final lazyUndoRedo = group.lazyUndoRedo<int>();
    final stream = group.stream<int>(readable.toStream);
    final streamRaw = group.streamRaw<int?>(readable.toStream);
    final future = group.future<int>(() async => 1);
    final list = group.list<int>([0]);
    final hashSet = group.hashSet<int>({0});
    final hashMap = group.hashMap<int, int>({0: 0});
    final derivedFuture = group.future<int>(() async => filtered() + 1);
    final derivedStream = group.streamRaw(Stream.empty);
    final periodic = group.periodic(k10ms, (i) => i + 1);

    group.effect(() {});

    // ignore: inference_failure_on_function_invocation, unnecessary_lambdas
    final _ = group.family((int i) => group.readable(i));

    expect(group.beaconCount, 25);
    expect(created, 25);

    cancel();

    group.writable(0);

    expect(group.beaconCount, 26);
    expect(created, 25);

    writable.increment();

    expect(writable(), 1);
    expect(derived(), 2);

    group.resetAll();

    expect(writable(), 0);
    expect(derived(), 1);

    group.disposeAll();

    expect(readable.isDisposed, true);
    expect(writable.isDisposed, true);
    expect(lazyWritable.isDisposed, true);
    expect(bufferedCount.isDisposed, true);
    expect(bufferedTime.isDisposed, true);
    expect(debounced.isDisposed, true);
    expect(lazyDebounced.isDisposed, true);
    expect(derived.isDisposed, true);
    expect(filtered.isDisposed, true);
    expect(lazyFiltered.isDisposed, true);
    expect(throttled.isDisposed, true);
    expect(lazyThrottled.isDisposed, true);
    expect(timestamp.isDisposed, true);
    expect(lazyTimestamp.isDisposed, true);
    expect(undoRedo.isDisposed, true);
    expect(lazyUndoRedo.isDisposed, true);
    expect(stream.isDisposed, true);
    expect(streamRaw.isDisposed, true);
    expect(future.isDisposed, true);
    expect(derived.isDisposed, true);
    expect(list.isDisposed, true);
    expect(hashSet.isDisposed, true);
    expect(hashMap.isDisposed, true);
    expect(derivedFuture.isDisposed, true);
    expect(derivedStream.isDisposed, true);
    expect(periodic.isDisposed, true);

    expect(group.beaconCount, 0);
  });
}
