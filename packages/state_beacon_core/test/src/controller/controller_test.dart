import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

class MyController extends BeaconController {
  late final count = B.writable(0);
  late final doubledCount = B.derived(() => count.value * 2);
}

void main() {
  test('should dispose all beacons created in controller', () {
    final controller = MyController();
    expect(controller.count.isDisposed, false);
    expect(controller.doubledCount.isDisposed, false);

    controller.dispose();

    expect(controller.count.isDisposed, true);
    expect(controller.doubledCount.isDisposed, true);
  });
}
