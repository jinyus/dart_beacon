import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  const k10ms = Duration(milliseconds: 10);

  group('FutureBeacon Tests', () {
    test('should change to AsyncData on successful future resolution',
        () async {
      var completer = Completer<String>();
      var futureBeacon = Beacon.future(() async => completer.future);

      completer.complete('result');
      await completer.future; // Wait for the future to complete

      expect(futureBeacon.value, isA<AsyncData<String>>());

      var data = futureBeacon.value as AsyncData<String>;
      expect(data.value, equals('result'));
    });

    test('should change to AsyncError on future error', () async {
      var futureBeacon =
          Beacon.future<String>(() async => throw Exception('error'));
      await Future.delayed(Duration(milliseconds: 100));
      expect(futureBeacon.value, isA<AsyncError>());

      var error = futureBeacon.value as AsyncError;

      expect(error.error, isA<Exception>());
    });

    test('should set initial state to AsyncLoading', () {
      var futureBeacon = Beacon.future(() async => 'result');
      expect(futureBeacon.value, isA<AsyncLoading>());
    });

    test('should re-executes the future on reset', () async {
      var counter = 0;

      var futureBeacon = Beacon.future(() async => ++counter);

      await Future.delayed(Duration(milliseconds: 100));

      futureBeacon.reset();

      expect(futureBeacon.value, isA<AsyncLoading>());

      await Future.delayed(Duration(milliseconds: 100));

      expect(futureBeacon.value, isA<AsyncData<int>>());

      final value = futureBeacon.value.unwrapValue();

      expect(value, equals(2));
    });

    test('should not executes until start() is called', () async {
      var counter = 0;

      var futureBeacon =
          Beacon.future(() async => ++counter, manualStart: true);

      expect(futureBeacon.value, isA<AsyncIdle>());

      await Future.delayed(Duration(milliseconds: 10));

      futureBeacon.start();

      expect(futureBeacon.value, isA<AsyncLoading>());

      await Future.delayed(Duration(milliseconds: 10));

      expect(futureBeacon.value, isA<AsyncData<int>>());

      final value = futureBeacon.value.unwrapValue();

      expect(value, equals(1));
    });
  });
  group('DerivedFutureBeacon Tests', () {
    test('should re-initializes when dependency changes', () async {
      var count = Beacon.writable(0);

      var ran = 0;

      var _ = Beacon.derivedFuture(() async {
        count.value;
        return ++ran;
      });

      await Future.delayed(Duration(milliseconds: 10));

      expect(ran, equals(1));

      count.value = 1; // Changing dependency

      await Future.delayed(Duration(milliseconds: 10));

      expect(ran, equals(2));
    });

    test('should clean up internal status beacon when disposed', () async {
      var count = Beacon.writable(0);

      var plus1 = Beacon.derivedFuture(() async {
        return count.value + 1;
      }, manualStart: true);

      final plus1Status = (plus1 as DerivedFutureBeacon).status;

      expect(plus1Status.value, DerivedFutureStatus.idle);

      plus1.start();

      await Future.delayed(k10ms);

      expect(plus1.value.unwrapValue(), equals(1));

      expect(plus1Status.value, DerivedFutureStatus.running);

      plus1.dispose();

      expect(plus1Status.value, DerivedFutureStatus.idle);
    });

    test('should await FutureBeacon exposed a future', () async {
      var count = Beacon.writable(0);
      var count2 = Beacon.writable(0);

      var firstName = Beacon.derivedFuture(() async {
        final val = count.value;
        await Future.delayed(k10ms);
        return 'Sally $val';
      });

      var lastName = Beacon.derivedFuture(() async {
        final val = count2.value + 1;
        await Future.delayed(k10ms);
        return 'Smith $val';
      });

      var fullName = Beacon.derivedFuture(() async {
        // final fname = await firstName.toFuture();

        // a change in this won't trigger a rerun because of the async gap
        // only values accessed before await will trigger a rerun
        // so Future.wait must be used to ensure both futures are accessed
        // final lname = await lastName.toFuture();

        final [fname, lname] = await Future.wait(
          [
            firstName.toFuture(),
            lastName.toFuture(),
          ],
        );

        final name = '$fname $lname';

        return name;
      });

      expect(fullName.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 2);

      expect(fullName.value.unwrapValue(), 'Sally 0 Smith 1');

      count.increment();

      expect(fullName.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 3);

      expect(fullName.value.unwrapValue(), 'Sally 1 Smith 1');

      count2.increment();

      expect(fullName.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 3);

      expect(fullName.value.unwrapValue(), 'Sally 1 Smith 2');
    });

    test('should return error when dependency throws error', () async {
      var count = Beacon.writable(0);

      var firstName = Beacon.derivedFuture(() async {
        final val = count.value;
        await Future.delayed(k10ms);
        if (val > 0) {
          throw Exception('error');
        }
        return 'Sally $val';
      });

      var greeting = Beacon.derivedFuture(() async {
        final fname = await firstName.toFuture();

        return 'Hello $fname';
      });

      expect(greeting.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 1.1);

      expect(greeting.value.unwrapValue(), 'Hello Sally 0');

      count.increment();

      expect(greeting.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 3);

      expect(greeting.value, isA<AsyncError>());
    });

    test('should not execute until start() is called', () async {
      var count = Beacon.writable(0);

      var ran = 0;

      var futureBeacon = Beacon.derivedFuture(() async {
        count.value;
        return ++ran;
      }, manualStart: true);

      await Future.delayed(Duration(milliseconds: 10));

      expect(ran, equals(0));

      futureBeacon.start();

      await Future.delayed(Duration(milliseconds: 10));

      expect(ran, equals(1));

      count.value = 1; // Changing dependency

      await Future.delayed(Duration(milliseconds: 10));

      expect(ran, equals(2));

      futureBeacon.reset();

      await Future.delayed(Duration(milliseconds: 10));

      expect(ran, equals(3));
    });
    test('should await StreamBeacon exposed a future', () async {
      Stream<int> idChanges() async* {
        yield 1;
        await Future.delayed(k10ms);
        yield 2;
        await Future.delayed(k10ms);
        yield 3;
      }

      Future<String> fetchUser(int id) async {
        await Future.delayed(k10ms);
        return 'User $id';
      }

      final id = Beacon.stream(idChanges());
      final user = Beacon.derivedFuture(() async {
        return fetchUser(await id.toFuture());
      });

      final results = <AsyncValue>[];
      final correctResults = [
        AsyncLoading<String>(),
        AsyncData('User 1'),
        AsyncLoading<String>(),
        AsyncData('User 2'),
        AsyncLoading<String>(),
        AsyncData('User 3'),
      ];

      Beacon.createEffect(() {
        results.add(user.value);
      });

      await Future.delayed(const Duration(seconds: 1));

      expect(results, correctResults);
    });
  });

  group('Stream tests', () {
    test('should emit values', () async {
      var myStream = Stream.periodic(k10ms * 10, (i) => i);
      var myBeacon = Beacon.stream(myStream);
      var called = 0;

      myBeacon.subscribe((value) {
        // print('called: $called with $value');
        if (called == 0) {
          expect(myBeacon.previousValue, isA<AsyncLoading>());
          expect(value, isA<AsyncData<int>>());
          called++;
        } else if (called < 3) {
          expect(myBeacon.previousValue, isA<AsyncData<int>>());
          expect(value.unwrapValue(), equals(called));

          if (called == 2) {
            myBeacon.unsubscribe();
          }

          called++;
        } else {
          throw Exception('Should not have been called');
        }
      });

      await Future.delayed(Duration(milliseconds: 400));

      expect(called, equals(3));
    });

    test('should be AsyncError when error is added to stream', () async {
      Stream<int> errorStream() async* {
        yield 1;
        await Future.delayed(k10ms);
        yield 2;
        await Future.delayed(k10ms);
        yield* Stream.error('error');
      }

      var myBeacon = Beacon.stream(errorStream());

      var called = 1;
      myBeacon.subscribe((value) {
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
      }, startNow: true);
    });

    test('should emit raw values', () async {
      var myStream = Stream.periodic(k10ms, (i) => i + 1);
      var myBeacon = Beacon.streamRaw(myStream, initialValue: 0);
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

      await Future.delayed(Duration(milliseconds: 50));

      expect(results, [0, 1, 2, 3, 4]);

      expect(called, equals(4));
    });

    test('should throw is initial value is empty and type is non-nullable',
        () async {
      var myStream = Stream.periodic(k10ms, (i) => i + 1);
      expect(() => Beacon.streamRaw(myStream), throwsAssertionError);
    });

    test('should execute onDone callback', () async {
      var myStream = Stream.periodic(k10ms * 0.1, (i) => i + 1).take(3);
      var called = 0;
      var myBeacon = Beacon.streamRaw(myStream, initialValue: 0, onDone: () {
        called++;
      });

      myBeacon.subscribe((value) {
        called++;
      });

      await Future.delayed(k10ms);

      expect(called, equals(4));
    });

    test('should do nothing on stream beacon is reset', () {
      final controller = StreamController<int>();
      var listeners = 0;
      var myStream = controller.stream.asBroadcastStream(
        onListen: (_) => listeners++,
        onCancel: (_) => listeners--,
      );
      var called = 0;
      var myRawBeacon = Beacon.streamRaw(myStream, initialValue: 0);
      var myBeacon = Beacon.stream(myStream);

      myBeacon.subscribe((value) {
        called++;
      });

      myRawBeacon.subscribe((value) {
        called++;
      });

      myBeacon.reset();
      myRawBeacon.reset();

      expect(called, equals(0));
      expect(listeners, 1);

      myRawBeacon.dispose();
      myBeacon.dispose();

      expect(listeners, 0);

      controller.close();
    });
  });
}
