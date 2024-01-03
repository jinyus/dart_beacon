import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should attach a timestamp to each value', () {
    var beacon = Beacon.timestamped(0);
    var timestampBefore = DateTime.now();
    beacon.set(10);
    var timestampAfter = DateTime.now();

    expect(beacon.value.value, equals(10)); // Check value
    expect(
      beacon.value.timestamp.isAfter(timestampBefore) &&
          beacon.value.timestamp.isBefore(timestampAfter),
      isTrue,
    );
  });
}
