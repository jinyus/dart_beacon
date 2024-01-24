import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should update value only if it satisfies the filter criteria', () {
    final beacon = Beacon.filtered(0, filter: (prev, next) => next > 5);
    beacon.value = 4;
    expect(beacon.value, equals(0)); // Value should not update

    beacon.value = 6;
    expect(beacon.value, equals(6)); // Value should update
  });

  test('should update value if filter function is null', () {
    final beacon = Beacon.filtered(0);
    beacon.value = 4;
    expect(beacon.value, equals(4)); // Value should update

    beacon.setFilter((p0, p1) => p1 > 10);

    beacon.value = 6;
    expect(beacon.value, equals(4)); // Value should not update

    beacon.value = 11;
    expect(beacon.value, equals(11)); // Value should update
  });

  test('should bypass filter function for first value', () {
    final beacon = Beacon.lazyFiltered<int>(filter: (prev, next) => next > 5);
    beacon.value = 4;
    expect(beacon.value, equals(4)); // Value should update

    beacon.value = 4;
    expect(beacon.value, equals(4)); // Value should not update

    beacon.value = 6;
    expect(beacon.value, equals(6)); // Value should update
  });

  test('should set hasFilter to false if not is provided', () {
    final beacon = Beacon.filtered(0);
    beacon.value = 4;
    expect(beacon.value, equals(4)); // Value should update

    expect(beacon.hasFilter, false);

    beacon.value = 5;
    expect(beacon.value, equals(5));

    beacon.setFilter((p0, p1) => p1 > 10);

    expect(beacon.hasFilter, true);

    beacon.value = 6;
    expect(beacon.value, equals(5)); // Value should not update

    beacon.value = 11;
    expect(beacon.value, equals(11)); // Value should update
  });
}
