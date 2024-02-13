import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should set initial value', () {
    final beacon = Beacon.readable(10);
    expect(beacon.peek(), equals(10));
  });

  test('should decrease listenersCount when unsubscribed', () async {
    final beacon = Beacon.readable(10);

    final unsub1 = beacon.subscribe((_) {});

    expect(beacon.listenersCount, 1);

    final unsub2 = Beacon.effect(() {
      beacon.value;
    });

    await BeaconScheduler.settle();

    expect(beacon.listenersCount, 2);

    unsub1();

    expect(beacon.listenersCount, 1);

    unsub2();

    expect(beacon.listenersCount, 0);
  });

  test('should fire subscription immediately', () async {
    final a = Beacon.readable(1);
    final completer = Completer<int>();

    a.subscribe(completer.complete);

    final result = await completer.future;

    expect(result, 1);
  });

  test('should return a stream', () async {
    final a = Beacon.writable(1);

    final stream = a.stream;

    var called = 0;

    final sub1 = stream.listen((v) => called++);
    final sub2 = stream.listen((v) => called++);
    final sub3 = stream.listen((v) => called++);

    await delay(k10ms);

    // all 3 is notified because the internal subscription is deferred
    expect(called, 3);

    a.increment();

    await delay(k1ms);

    // all subs get notified
    expect(called, 6);

    await delay(k1ms);

    await sub1.cancel();

    await sub2.cancel();

    a.increment();

    await delay(k1ms);

    expect(called, 7);

    await sub3.cancel();

    await delay(k1ms);

    a.increment();

    await delay(k1ms);

    expect(called, 7);

    final sub4 = stream.listen((v) => called++);

    await delay(k1ms);

    expect(called, 8);

    a.increment();

    await delay(k1ms);

    expect(called, 9);

    await sub4.cancel();

    await delay(k1ms);

    a.increment();

    expect(called, 9);
  });
}
