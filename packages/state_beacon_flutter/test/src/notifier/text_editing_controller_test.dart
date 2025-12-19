import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon_flutter/state_beacon_flutter.dart';

void main() {
  test('should be synced with internal TextEditingController', () async {
    final beacon = TextEditingBeacon();
    final controller = beacon.controller;

    expect(beacon.peek(), TextEditingValue.empty);
    expect(beacon.text, '');
    expect(controller.text, '');

    beacon.text = '1';

    expect(beacon.text, '1');
    expect(controller.text, '1');

    beacon.text = '2';

    expect(beacon.text, '2');
    expect(controller.text, '2');

    beacon.clear();

    expect(beacon.text, '');
    expect(controller.text, '');

    controller.text = '3';

    expect(beacon.text, '3');
    expect(controller.text, '3');

    controller.clear();

    expect(beacon.text, '');
    expect(controller.text, '');

    controller.dispose();

    expect(beacon.isDisposed, true);
  });

  test('should reflect changes to the controller', () async {
    final beacon = TextEditingBeacon(text: '1');
    final controller = beacon.controller;

    expect(beacon.text, '1');
    expect(controller.text, '1');

    expect(beacon.selection, controller.selection);

    beacon.value = const TextEditingValue(text: 'hello');
    expect(controller.text, 'hello');

    beacon.text = 'goodbye';
    expect(controller.text, 'goodbye');
  });

  test('should add beacon to group provided', () {
    final group = BeaconGroup();
    final beacon = group.textEditing(text: '1');

    expect(group.beacons.length, 1);
    expect(group.beacons.first, beacon);

    group.disposeAll();

    expect(group.beacons.isEmpty, true);

    expect(beacon.isDisposed, true);
  });

  test('should call dispose once', () {
    final beacon = TextEditingBeacon(text: '1');
    var called = 0;

    beacon
      ..onDispose(() => called++)
      ..dispose();

    expect(called, 1);
  });
}
