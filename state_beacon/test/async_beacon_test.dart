import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
    test('should await derivedFuture asFuture', () async {
      var count = Beacon.writable(0);

      var firstName = Beacon.derivedFuture(() async {
        final val = count.value;
        await Future.delayed(k10ms);
        return 'Sally $val';
      });

      var lastName = Beacon.derivedFuture(() async {
        final val = count.value + 1;
        await Future.delayed(k10ms);
        return 'Smith $val';
      });

      var fullName = Beacon.derivedFuture(() async {
        count.value; // register dependency

        final fname = await firstName.asFuture;
        final lname = await lastName.asFuture;

        return '$fname $lname';
      });

      expect(fullName.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 3);

      expect(fullName.value.unwrapValue(), 'Sally 0 Smith 1');

      count.increment();

      expect(fullName.value, isA<AsyncLoading>());

      await Future.delayed(k10ms * 3);

      expect(fullName.value.unwrapValue(), 'Sally 1 Smith 2');
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
  });

  group('Stream tests', () {
    test('should  emit values', () async {
      var myStream = Stream.periodic(Duration(milliseconds: 100), (i) => i);
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
  });
}
