import 'package:counter/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('emits [1] when incremented', () async {
    final controller = Controller();

    expect(controller.count.value, 0);

    final emitted = controller.count.buffer(2);

    BeaconScheduler.flush();

    controller.increment();

    BeaconScheduler.flush();

    expect(emitted.value, [0, 1]);
  });

  test('emits [-1] when decremented', () async {
    final controller = Controller();

    expect(controller.count.value, 0);

    final emitted = controller.count.buffer(2);

    BeaconScheduler.flush();

    controller.decrement();

    BeaconScheduler.flush();

    expect(emitted.value, [0, -1]);
  });
}
