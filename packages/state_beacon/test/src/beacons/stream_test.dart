// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should emit values', () async {
    final myStream = Stream.periodic(k10ms, (i) => i);
    final myBeacon = Beacon.stream(myStream);

    expect(
      myBeacon.toStream(),
      emitsInOrder([
        isA<AsyncLoading>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
        isA<AsyncData<int>>(),
      ]),
    );
  });

  test('should be AsyncError when error is added to stream', () async {
    Stream<int> errorStream() async* {
      yield 1;
      await Future<void>.delayed(k1ms);
      yield 2;
      await Future<void>.delayed(k1ms);
      yield* Stream.error('error');
    }

    final myBeacon = Beacon.stream(errorStream());

    expect(
      myBeacon.toStream(),
      emitsInOrder(
        [
          isA<AsyncLoading>(),
          isA<AsyncData<int>>(),
          isA<AsyncData<int>>(),
          isA<AsyncError>(),
        ],
      ),
    );
  });

  test('should emit raw values', () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    final beacon = Beacon.streamRaw(myStream, initialValue: 0);

    final buffered = beacon.buffer(5);

    await expectLater(buffered.next(), completion(equals([0, 1, 2, 3, 4])));
  });

  test('should throw if initial value is empty and type is non-nullable',
      () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    expect(() => Beacon.streamRaw(myStream), throwsAssertionError);
  });

  test('should execute onDone callback', () async {
    final myStream = Stream.periodic(k10ms, (i) => i + 1).take(3);

    var done = false;

    final myBeacon = Beacon.streamRaw<int?>(
      myStream,
      onDone: () => done = true,
    );

    final buffered = myBeacon.buffer(4);

    await expectLater(buffered.next(), completion(equals([null, 1, 2, 3])));

    await Future<void>.delayed(k1ms);

    expect(done, true);

    expect(myBeacon.isDisposed, true);
    expect(buffered.isDisposed, true);
  });
}