import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should update value only after specified duration', () async {
    final beacon = Beacon.debounced('', duration: k10ms);
    var called = 0;

    beacon.subscribe((_) => called++);

    // simulate typing
    beacon.value = 'a';
    beacon.value = 'ap';
    beacon.value = 'app';
    beacon.value = 'appl';
    beacon.value = 'apple';

    // Value should still be 0 immediately after setting it
    expect(beacon.value, equals(''));

    await Future<void>.delayed(k10ms * 2);

    expect(beacon.value, equals('apple')); // Value should be updated now

    expect(called, equals(1)); // Only one notification should be sent
  });
}
