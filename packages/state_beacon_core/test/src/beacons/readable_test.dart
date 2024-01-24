import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should set initial value', () {
    final beacon = Beacon.readable(10);
    expect(beacon.peek(), equals(10));
  });

  test('should decrease listenersCount when unsubscribed', () {
    final beacon = Beacon.readable(10);

    final unsub1 = beacon.subscribe((_) {});

    expect(beacon.listenersCount, 1);

    final unsub2 = Beacon.effect(() {
      beacon.value;
    });

    expect(beacon.listenersCount, 2);

    unsub1();

    expect(beacon.listenersCount, 1);

    unsub2();

    expect(beacon.listenersCount, 0);
  });

  test('should fire subscription immediately', () async {
    final a = Beacon.readable(1);
    final completer = Completer<int>();

    a.subscribe(completer.complete, startNow: true);

    final result = await completer.future;

    expect(result, 1);
  });
}
