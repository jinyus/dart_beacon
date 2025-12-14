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
    final buff = beacon.bufferTime(k1ms);

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

  test('should ignore errors when stream throws', () async {
    Stream<List<int>> getStream() async* {
      yield [1, 2, 3];
      await delay(k10ms);
      yield [4, 5, 6];
      await delay(k10ms);
      throw Exception('error');
    }

    final s = Beacon.streamRaw(
      getStream,
      name: 's',
      initialValue: <int>[],
      shouldSleep: false,
      onError: (e, s) {},
    );

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

  test('should sleep when it has no more observers', () async {
    final controller = StreamController<int>.broadcast();

    final num1 = Beacon.writable(5);

    // should increment when dependency changes
    var unsubs = 0;
    var listens = 0;

    controller.onCancel = () => unsubs++;

    controller.onListen = () {
      listens++;
      addItems(controller, num1.value);
    };

    var ran = 0;

    final beacon = Beacon.streamRaw<int?>(
      () {
        ran++;
        num1.value;
        return controller.stream;
      },
    );

    final unsub = Beacon.effect(() => beacon.value);

    expect(num1.listenersCount, 0);
    expect(beacon.listenersCount, 0);

    BeaconScheduler.flush();

    expect(listens, 1);
    expect(ran, 1);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    unsub();

    await delay();

    expect(listens, 1);
    expect(unsubs, 1);
    expect(ran, 1);
    expect(num1.listenersCount, 0);
    expect(beacon.listenersCount, 0);

    num1.increment(); // dep changed, should unsub from old stream

    BeaconScheduler.flush();

    expect(listens, 1);
    expect(unsubs, 1);
    expect(ran, 1);
    expect(num1.listenersCount, 0);
    expect(beacon.listenersCount, 0);

    final unsub2 = Beacon.effect(() => beacon.value);

    BeaconScheduler.flush();

    expect(listens, 2);
    expect(unsubs, 1);
    expect(ran, 2);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    unsub2();

    await delay();

    expect(listens, 2);
    expect(unsubs, 2); // should unsub when it has no more listeners
    expect(ran, 2);
    expect(num1.listenersCount, 0);
    expect(beacon.listenersCount, 0);

    final unsub3 = Beacon.effect(() => beacon.value);
    final unsub4 = Beacon.effect(() => beacon.value);

    BeaconScheduler.flush();

    expect(listens, 3); // should start listen again
    expect(unsubs, 2);
    expect(ran, 3);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 2);

    unsub3();

    await delay();

    expect(listens, 3);
    expect(unsubs, 2); // still has 1 listener, should not unsub
    expect(ran, 3);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    unsub4();

    await delay();

    expect(listens, 3);
    expect(unsubs, 3); // should unsub when it has no more listeners
    expect(ran, 3);
    expect(num1.listenersCount, 0);
    expect(beacon.listenersCount, 0);

    expect(beacon.peek(), isPositive);

    await delay();

    expect(listens, 4); // should awake again
    expect(unsubs, 3);
    expect(ran, 4);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 0);
  });

  test('should not sleep when shouldSleep=false', () async {
    // BeaconObserver.instance = LoggingObserver();
    final controller = StreamController<int>.broadcast();

    final num1 = Beacon.writable(5, name: 'num1');

    // should increment when dependency changes
    var unsubs = 0;
    var listens = 0;

    controller.onCancel = () => unsubs++;

    controller.onListen = () {
      listens++;
      addItems(controller, num1.value);
    };

    var ran = 0;

    final beacon = Beacon.streamRaw<int?>(
      () {
        ran++;
        num1.value;
        return controller.stream;
      },
      shouldSleep: false,
      name: 's',
    );

    final unsub = Beacon.effect(() => beacon.value);

    expect(num1.listenersCount, 0);
    expect(beacon.listenersCount, 0);

    BeaconScheduler.flush();

    expect(listens, 1);
    expect(ran, 1);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 1);

    unsub();

    expect(listens, 1);
    expect(unsubs, 0); // should not unsub
    expect(ran, 1);
    expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 0);

    num1.increment(); // dep changed, should unsub from old stream

    BeaconScheduler.flush();

    expect(listens, 2);
    expect(unsubs, 1);
    expect(ran, 2);
    // expect(num1.listenersCount, 1);
    expect(beacon.listenersCount, 0);
  });

  test('should pause and resume internal stream', () async {
    final myStream = Stream.periodic(k10ms, (i) => i + 1);
    final myBeacon = Beacon.streamRaw(
      () => myStream,
      shouldSleep: false,
      isLazy: true,
    );

    final next = await myBeacon.next();

    expect(next, 1);

    myBeacon.pause();

    await delay();

    expect(myBeacon(), next); // should be the same value

    myBeacon.resume();

    final next2 = await myBeacon.next();

    expect(next2, 2);

    myBeacon.unsubscribe();

    await delay();

    final next3 = await myBeacon.next().timeout(k10ms, onTimeout: () => -1);

    expect(next3, -1);
  });

  test('should mirror values to stream getter', () async {
    final stream = Stream.fromIterable([1, 2, 3]);

    late final s = Beacon.streamRaw(() => stream, initialValue: 0);

    expect(s.stream, emitsInOrder([0, 1, 2, 3]));
  });

  test('should cancel subscription to old stream', () async {
    // BeaconObserver.useLogging(includeNames: ['b']);
    Stream<int> getStream(int limit) async* {
      for (var i = 0; i < limit; i++) {
        yield i;
        await delay(k10ms);
      }
    }

    final count = Beacon.writable(10);

    final s = Beacon.streamRaw(() => getStream(count.value), isLazy: true);

    final buffered = s.bufferTime(k10ms * 10);

    await delay(k1ms * 16); // only 0 and 1 in the first 16 ms

    expect(buffered.currentBuffer(), [0, 1]);

    // change dependency so it should unsub from old stream
    // new stream should emit 0,1,2,3
    count.value = 4;

    await expectLater(
      buffered.next(),
      completion([
        0,
        1,
        0,
        1,
        2,
        3,
      ]),
    );
  });
}
