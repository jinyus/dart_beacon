import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should update value only after specified duration', () async {
    final beacon = Beacon.debounced('', duration: k10ms);
    var called = 0;

    beacon
      ..subscribe((_) => called++)

      // simulate typing
      ..value = 'a'
      ..value = 'ap'
      ..value = 'app'
      ..value = 'appl'
      ..value = 'apple';

    // Value should still be 0 immediately after setting it
    expect(beacon.value, equals(''));

    await delay(k10ms * 2);

    expect(beacon.value, equals('apple')); // Value should be updated now

    expect(called, equals(1)); // Only one notification should be sent
  });
}
