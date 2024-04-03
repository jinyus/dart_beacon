import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/extensions/value_notifier.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should be synced with source value notifier', () async {
    final notifier = ValueNotifier(0);
    final beacon = notifier.toBeacon();

    expect(beacon.peek(), 0);

    notifier.value = 1;

    expect(beacon.value, 1);

    notifier.value = 2;

    expect(beacon.value, 2);

    beacon.increment();

    expect(beacon.value, 3);

    expect(notifier.value, 3);
  });
}
