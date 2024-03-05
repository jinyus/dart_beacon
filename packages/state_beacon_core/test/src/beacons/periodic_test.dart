import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should have initial value', () {
    final myBeacon = Beacon.periodic(k10ms, (i) => i + 1);
    expect(myBeacon.peek(), 1);
  });

  test('should emit values periodically', () async {
    final myBeacon = Beacon.periodic(k10ms, (i) => i + 1);

    final nextFive = await myBeacon.buffer(5).next();

    expect(nextFive, [1, 2, 3, 4, 5]);

    myBeacon.dispose();

    expect(myBeacon.isDisposed, true);
  });

  test('should pause and resume emition of values', () async {
    // BeaconObserver.useLogging();

    final myBeacon = Beacon.periodic(k10ms, (i) => i + 1);

    final buff = myBeacon.buffer(5);

    await delay(k10ms * 2);

    final length = buff.currentBuffer().length;

    expect(length, inInclusiveRange(1, 3));

    myBeacon.pause();

    await delay(k10ms * 4);

    expect(buff.currentBuffer().length, length);

    myBeacon.resume();

    final nextFive = await buff.next();

    expect(nextFive, [1, 2, 3, 4, 5]);
  });
}
