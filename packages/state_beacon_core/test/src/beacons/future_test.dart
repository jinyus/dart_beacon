// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';
import '../async_value_test.dart';

void main() {
  test('should change to AsyncData on successful future resolution', () async {
    final completer = Completer<String>();
    final futureBeacon = Beacon.future(() async => completer.future);

    completer.complete('result');
    await completer.future; // Wait for the future to complete

    expect(futureBeacon.value, isA<AsyncData<String>>());

    final data = futureBeacon.value as AsyncData<String>;
    expect(data.value, equals('result'));
  });

  test('should change to AsyncError on future error', () async {
    final futureBeacon = Beacon.future<String>(
      () async => throw Exception('error'),
    );

    expect(futureBeacon.isLoading, true);

    await delay(k10ms);

    expect(futureBeacon.value, isA<AsyncError>());

    final error = futureBeacon.value as AsyncError;

    expect(error.error, isA<Exception>());
  });

  test('should set initial state to AsyncLoading', () {
    final futureBeacon = Beacon.future(() async => 'result');
    expect(futureBeacon.isLoading, true);
    expect(futureBeacon.isIdleOrLoading, true);
  });

  test('should re-executes the future on reset', () async {
    var counter = 0;

    final futureBeacon = Beacon.future(() async => ++counter);

    expect(futureBeacon.isLoading, true);

    await delay(k1ms);

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.reset();

    expect(futureBeacon.isLoading, true);

    await delay(k1ms);

    expect(futureBeacon.isData, isTrue);

    expect(futureBeacon.unwrapValue(), 2);
  });

  test('should not executes until start() is called', () async {
    var counter = 0;

    final futureBeacon = Beacon.future(
      () async => ++counter,
      manualStart: true,
    );

    expect(futureBeacon.isIdle, true);

    await delay(k1ms);

    expect(counter, 0);

    futureBeacon.start();

    expect(futureBeacon.isLoading, true);

    await delay(k1ms);

    expect(futureBeacon.isData, isTrue);

    expect(futureBeacon.unwrapValue(), equals(1));
  });

  test('should override internal function', () async {
    final futureBeacon = Beacon.future(() async => testFuture(false));

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.overrideWith(() async => testFuture(true));

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.isError, isTrue);
  });

  test('should reset when data expires', () async {
    var count = 1;
    final futureBeacon = Beacon.future(() async => 'result $count', ttl: k10ms);

    expect(futureBeacon.isLoading, isTrue);

    final result = await futureBeacon.next();

    expect(result.unwrap(), 'result 1');

    // the data should expire in 10ms so the new count should be picked up
    // when the future is re-executed
    count++;

    final next = await futureBeacon.next();

    // should enter loading state after ttl expires
    expect(next.isLoading, isTrue);

    final result2 = await futureBeacon.next();

    expect(result2.unwrap(), 'result 2');
  });

  test('should follow ttl when overriden', () async {
    final futureBeacon = Beacon.future(() => testFuture(false), ttl: k10ms);

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.overrideWith(() async => testFuture(false));

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    // results of executing the overriden future
    expect(futureBeacon.unwrapValue(), 1);

    // after a succesful override, the ttl should be reset
    // so the future should be re-executed after 10ms
    // yielding a loading state
    final result = await futureBeacon.next();

    expect(result.isLoading, isTrue);

    final result2 = await futureBeacon.next();

    expect(result2.unwrap(), 1);
  });

  test('should ignore ttl when overriden', () async {
    final futureBeacon = Beacon.future(() => testFuture(false), ttl: k10ms);

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.overrideWith(() async => testFuture(true));

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.isError, isTrue);

    await delay();

    // ttl has passed but the future
    // was overriden so it should not be re-executed
    // as the last value was an error
    expect(futureBeacon.isLoading, isFalse);

    expect(futureBeacon.isError, isTrue);
  });
}
