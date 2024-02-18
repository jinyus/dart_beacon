// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';
import 'stream_test.dart';

void main() {
  test('should emit raw values', () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    final beacon = Beacon.streamRaw(() => myStream, initialValue: 0);

    final buffered = beacon.buffer(5);

    await expectLater(buffered.next(), completion(equals([0, 1, 2, 3, 4])));
  });

  test('should unsubscribe from internal stream', () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    final beacon = Beacon.streamRaw(() => myStream, initialValue: 0);

    final buffered = beacon.buffer(5);

    await expectLater(buffered.next(), completion(equals([0, 1, 2, 3, 4])));

    beacon.unsubscribe();

    await delay(k10ms);

    expect(buffered.value, [0, 1, 2, 3, 4]);
  });

  test('should throw if initial value is empty and type is non-nullable',
      () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    expect(
      () => Beacon.streamRaw(() => myStream),
      throwsA(isA<AssertionError>()),
    );
  });

  test('should execute onDone callback', () async {
    final myStream = Stream.periodic(k10ms, (i) => i + 1).take(3);

    var done = false;

    final myBeacon = Beacon.streamRaw<int?>(
      () => myStream,
      onDone: () => done = true,
    );

    final buffered = myBeacon.buffer(4);

    await expectLater(buffered.next(), completion(equals([null, 1, 2, 3])));

    await delay(k1ms);

    expect(done, true);

    myBeacon.dispose();

    expect(myBeacon.isDisposed, true);
    expect(buffered.isDisposed, true);
  });

  test('should be equal to beacon with the same stream', () async {
    final myBeacon = Beacon.streamRaw(Stream<int>.empty, initialValue: 0);
    final myBeacon2 = Beacon.streamRaw(Stream<int>.empty, initialValue: 0);

    BeaconScheduler.flush();

    expect(myBeacon, myBeacon2);
  });

  test('should unsub from old stream when dependency changes', () async {
    final controller = StreamController<int>.broadcast();

    final counter = Beacon.writable(5);

    // should increment when dependency changes
    var unsubs = 0;
    var listens = 0;

    controller.onCancel = () => unsubs++;

    controller.onListen = () {
      listens++;
      addItems(controller, counter.value);
    };

    final beacon = Beacon.streamRaw(
      () {
        counter.value;
        return controller.stream;
      },
      isLazy: true,
    );
    final buff = beacon.bufferTime(duration: k1ms);

    expect(buff.value, isEmpty);

    BeaconScheduler.flush();

    expect(listens, 1);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4]));

    counter.increment(); // dep changed, should unsub from old stream

    BeaconScheduler.flush();

    expect(unsubs, 1);
    expect(listens, 2);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4, 5]));

    counter.increment();

    BeaconScheduler.flush();

    expect(unsubs, 2); // dep changed, should unsub from old stream
    expect(listens, 3);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4, 5, 6]));

    beacon.dispose(); // should unsub when disposed

    expect(unsubs, 3);
    expect(listens, 3);
  });

  test('should ignore error when stream throws', () async {
    Stream<List<int>> getStream() async* {
      yield [1, 2, 3];
      await delay(k10ms);
      yield [4, 5, 6];
      await delay(k10ms);
      throw Exception('error');
    }

    final s = Beacon.streamRaw(getStream, name: 's', initialValue: <int>[]);

    final d = Beacon.derived(
      () {
        final res = s.value;
        return res;
      },
      name: 'd',
    );

    await expectLater(
      d.stream,
      emitsInOrder([
        <int>[],
        [1, 2, 3],
        [4, 5, 6],
      ]),
    );
  });
}
