import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should convert to a value notifier', () {
    var beacon = Beacon.writable(0);

    var valueNotifier = beacon.toValueNotifier();

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
}
