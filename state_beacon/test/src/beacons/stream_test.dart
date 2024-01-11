// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should emit values', () async {
    final myStream = Stream.periodic(k10ms, (i) => i);
    final myBeacon = Beacon.stream(myStream);
    var called = 0;

    myBeacon.subscribe((value) {
      // print('called: $called with $value');
      if (called == 0) {
        expect(myBeacon.previousValue, isA<AsyncLoading>());
        expect(value, isA<AsyncData<int>>());
        called++;
      } else if (called < 3) {
        expect(myBeacon.previousValue, isA<AsyncData<int>>());
        expect(value.unwrap(), equals(called));

        if (called == 2) {
          myBeacon.unsubscribe();
        }

        called++;
      } else {
        throw Exception('Should not have been called');
      }
    });

    await Future<void>.delayed(k10ms * 5);

    expect(called, equals(3));
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

    var called = 1;
    myBeacon.subscribe(
      (value) {
        if (called == 1) {
          expect(value, isA<AsyncLoading>());
        } else if (called == 2) {
          expect(value, isA<AsyncData<int>>());
        } else if (called == 3) {
          expect(value, isA<AsyncData<int>>());
        } else if (called == 4) {
          expect(value, isA<AsyncError>());
        } else {
          throw Exception('Should not have been called');
        }
        called++;
      },
      startNow: true,
    );
  });

  test('should emit raw values', () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    final myBeacon = Beacon.streamRaw(myStream, initialValue: 0);
    var called = 0;

    final results = <int?>[];

    myBeacon.subscribe((value) {
      // print('called: $called with $value');
      if (called == 0) {
        results.add(myBeacon.previousValue);
      }

      results.add(value);

      if (called == 3) {
        myBeacon.unsubscribe();
      }
      called++;
    });

    await Future<void>.delayed(k10ms * 5);

    expect(results, [0, 1, 2, 3, 4]);

    expect(called, equals(4));
  });

  test('should throw is initial value is empty and type is non-nullable',
      () async {
    final myStream = Stream.periodic(k1ms, (i) => i + 1);
    expect(() => Beacon.streamRaw(myStream), throwsAssertionError);
  });

  test('should execute onDone callback', () async {
    final myStream = Stream.periodic(k10ms, (i) => i + 1).take(3);
    var called = 0;
    var done = false;
    final myBeacon = Beacon.streamRaw(
      myStream,
      initialValue: 0,
      onDone: () {
        done = true;
      },
    );

    // ignore: cascade_invocations
    myBeacon.subscribe((value) {
      called++;
    });

    await Future<void>.delayed(k10ms * 4);

    expect(called, equals(3));
    expect(done, true);
  });
}
