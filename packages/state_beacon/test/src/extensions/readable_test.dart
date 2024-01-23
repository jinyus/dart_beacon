import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should convert to a value listenable', () {
    var beacon = Beacon.writable(0);

    var valueNotifier = beacon.toListenable();

    expect(valueNotifier, isA<ValueListenable<int>>());

    var called = 0;

    fn() => called++;
    valueNotifier.addListener(fn);

    beacon.value = 1;

    expect(called, 1);

    beacon.value = 2;

    expect(called, 2);

    valueNotifier.removeListener(fn);

    beacon.value = 3;

    expect(called, 2);
  });
}
