import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';
import '../async_value_test.dart';

void main() {
  test('should change to AsyncData on successful future resolution', () async {
    var completer = Completer<String>();
    var futureBeacon = Beacon.future(() async => completer.future);

    completer.complete('result');
    await completer.future; // Wait for the future to complete

    expect(futureBeacon.value, isA<AsyncData<String>>());

    var data = futureBeacon.value as AsyncData<String>;
    expect(data.value, equals('result'));
  });

  test('should change to AsyncError on future error', () async {
    var futureBeacon = Beacon.future<String>(
      () async => throw Exception('error'),
    );
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

    var futureBeacon = Beacon.future(() async => ++counter, manualStart: true);

    expect(futureBeacon.value, isA<AsyncIdle>());

    await Future.delayed(Duration(milliseconds: 10));

    futureBeacon.start();

    expect(futureBeacon.value, isA<AsyncLoading>());

    await Future.delayed(Duration(milliseconds: 10));

    expect(futureBeacon.value, isA<AsyncData<int>>());

    final value = futureBeacon.value.unwrapValue();

    expect(value, equals(1));
  });

  test('should override internal function', () async {
    var futureBeacon = Beacon.future(() async => testFuture(false));

    expect(futureBeacon.value.isLoading, isTrue);

    await Future.delayed(k1ms);

    expect(futureBeacon.value.unwrapValue(), 1);

    futureBeacon.overrideWith(() async => testFuture(true));

    expect(futureBeacon.value.isLoading, isTrue);

    await Future.delayed(k1ms);

    expect(futureBeacon.value, isA<AsyncError>());
  });
}
