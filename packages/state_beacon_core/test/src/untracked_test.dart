import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should not send notification when doing untracked access', () {
    final age = Beacon.writable<int>(10);
    final name = Beacon.writable<String>('John');

    var callCount = 0;

    Beacon.effect(() {
      age.value;
      callCount++;
      Beacon.untracked(() {
        name.value;
      });
    });

    BeaconScheduler.flush();

    expect(callCount, equals(1));

    age.value = 20;
    BeaconScheduler.flush();
    expect(callCount, equals(2));

    name.value = 'Jane';
    BeaconScheduler.flush();
    expect(callCount, equals(2));
  });
}
