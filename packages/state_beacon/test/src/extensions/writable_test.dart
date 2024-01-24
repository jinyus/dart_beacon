import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should convert to a value notifier', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toValueNotifier();

    expect(valueNotifier, isA<ValueNotifier<int>>());

    var called = 0;

    valueNotifier.addListener(() => called++);

    beacon.value = 1;

    expect(called, 1);

    beacon.value = 2;

    expect(called, 2);

    valueNotifier.dispose();

    beacon.value = 3;

    expect(called, 2);
  });

  test('should not notify after source beacon is disposed', () {
    final beacon = Beacon.writable(0);

    final valueNotifier = beacon.toValueNotifier();

    expect(valueNotifier, isA<ValueNotifier<int>>());

    var called = 0;

    valueNotifier.addListener(() => called++);

    beacon.value = 1;

    expect(called, 1);

    beacon.value = 2;

    expect(called, 2);

    beacon
      ..dispose()
      ..value = 3;

    expect(called, 2);
  });
}
