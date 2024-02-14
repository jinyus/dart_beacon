// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

Stream<int> sampleStream(int len) {
  return Stream.fromIterable(List.generate(len, (i) => i));
}

void addItems(StreamController<int> controller, int len) {
  for (var i = 0; i < len; i++) {
    controller.add(i);
  }
}

void main() {
  test('should emit values', () async {
    final myStream = Stream.periodic(k10ms, (i) => i);
    final myBeacon = Beacon.stream(() => myStream);

    expect(
      myBeacon.stream,
      emitsInOrder([
        isA<AsyncLoading<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
      ]),
    );
  });

  test('should be AsyncError when error is added to stream', () async {
    Stream<int> errorStream() async* {
      yield 1;
      await delay(k1ms);
      yield 2;
      await delay(k1ms);
      yield* Stream.error('error');
    }

    final myBeacon = Beacon.stream(errorStream);

    expect(
      myBeacon.stream,
      emitsInOrder(
        [
          isA<AsyncLoading<int>>(),
          isA<AsyncData<int>>(),
          isA<AsyncData<int>>(),
          isA<AsyncError<int>>(),
        ],
      ),
    );
  });

  test('should not start stream until start() is called', () async {
    final myStream = Stream.periodic(k10ms, (i) => i + 1);
    final myBeacon = Beacon.stream(() => myStream, manualStart: true);

    expect(myBeacon.isIdle, true);

    myBeacon.start();

    BeaconScheduler.flush();

    expect(myBeacon.isLoading, true);

    final next = await myBeacon.next();

    expect(next.isData, true);
  });

  test('should pause and resume internal stream', () async {
    final myStream = Stream.periodic(k10ms, (i) => i + 1);
    final myBeacon = Beacon.stream(() => myStream, manualStart: true);

    expect(myBeacon.isIdle, true);

    myBeacon.start();

    BeaconScheduler.flush();

    expect(myBeacon.isLoading, true);

    final next = await myBeacon.next();

    expect(next.isData, true);

    myBeacon.pause();

    await delay();

    expect(myBeacon.unwrapValue(), next.unwrap()); // should be the same value

    myBeacon.resume();

    final next2 = await myBeacon.next();

    expect(next2.isData, true);

    expect(next2.unwrap(), isNot(next.unwrap())); // should be new value
  });

  test('should set last data in loading and error states', () async {
    final controller = StreamController<int>();
    final myBeacon = Beacon.stream(() => controller.stream);

    expect(myBeacon.isLoading, true);

    controller.add(1);

    var next = await myBeacon.next();

    expect(next.isData, true);

    expect(next.unwrap(), 1);

    controller.addError('error');

    next = await myBeacon.next(timeout: k1ms);

    expect(next.isError, true);

    expect(next.lastData, 1);
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

    final beacon = Beacon.stream(
      () {
        counter.value;
        return controller.stream;
      },
    );
    final buff = beacon.bufferTime(duration: k1ms);

    expect(buff.value, isEmpty);

    BeaconScheduler.flush();

    expect(listens, 1);

    await expectLater(
      buff.next(),
      completion([
        isA<AsyncLoading<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
      ]),
    );

    counter.increment(); // dep changed, should unsub from old stream

    BeaconScheduler.flush();

    expect(unsubs, 1);
    expect(listens, 2);

    await expectLater(
      buff.next(),
      completion([
        isA<AsyncLoading<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        AsyncData<int>(5),
      ]),
    );

    counter.increment();

    BeaconScheduler.flush();

    expect(unsubs, 2); // dep changed, should unsub from old stream
    expect(listens, 3);

    await expectLater(
      buff.next(),
      completion([
        isA<AsyncLoading<int>>(),
        AsyncData<int>(0),
        AsyncData<int>(1),
        AsyncData<int>(2),
        AsyncData<int>(3),
        AsyncData<int>(4),
        AsyncData<int>(5),
        AsyncData<int>(6),
      ]),
    );

    beacon.dispose(); // should unsub when disposed

    expect(unsubs, 3);
    expect(listens, 3);
  });
}
