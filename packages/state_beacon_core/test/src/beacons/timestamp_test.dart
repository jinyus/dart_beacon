import 'package:state_beacon_core/src/creator/creator.dart';
import 'package:test/test.dart';

void main() {
  test('should attach a timestamp to each value', () {
    final beacon = Beacon.timestamped(0);
    final timestampBefore = DateTime.now();
    beacon.set(10);
    final timestampAfter = DateTime.now();

    expect(beacon.value.value, equals(10)); // Check value
    expect(
      beacon.value.timestamp.isAfter(timestampBefore) &&
          beacon.value.timestamp.isBefore(timestampAfter),
      isTrue,
    );
  });
}
