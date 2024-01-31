import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  group('BufferedCountBeacon', () {
    test('should buffer values until count is reached', () {
      final beacon = Beacon.bufferedCount<int>(3);
      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2)
        ..add(3); // This should trigger the buffer to be set

      expect(buffer, equals([1, 2, 3]));
    });

    test('should clear buffer after reaching count threshold', () {
      final beacon = Beacon.bufferedCount<int>(2);

      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2); // First trigger

      expect(buffer, equals([1, 2]));

      expect(beacon.currentBuffer.value, equals([]));

      beacon.add(3);

      expect(beacon.currentBuffer.value, equals([3]));

      beacon.add(4); // Second trigger

      expect(buffer, equals([3, 4]));
    });

    test('should update currentBuffer', () {
      final beacon = Beacon.bufferedCount<int>(3);

      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2);

      expect(beacon.currentBuffer.value, equals([1, 2]));

      beacon
        ..add(3) // This should trigger the buffer to be set
        ..add(4);

      expect(beacon.currentBuffer.value, equals([4]));

      expect(buffer, equals([1, 2, 3]));
    });

    test('should reset', () {
      final beacon = Beacon.bufferedCount<int>(3);

      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2)
        ..reset();

      expect(beacon.currentBuffer.value, equals([]));
      expect(buffer, equals([]));
    });
  });

  group('BufferedTimeBeacon', () {
    test('should buffer values over a time duration', () async {
      final beacon = Beacon.bufferedTime<int>(duration: k10ms * 5);

      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2);

      await delay(k10ms);

      expect(buffer, equals([]));

      await delay(k10ms * 5);

      expect(buffer, equals([1, 2]));
    });

    test('should reset buffer after time duration', () async {
      final beacon = Beacon.bufferedTime<int>(duration: k10ms * 3);

      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);

      await delay(k10ms * 4);

      expect(beacon.currentBuffer.value, equals([]));

      expect(buffer, equals([1, 2, 3, 4]));
    });

    test('should reset', () async {
      final beacon = Beacon.bufferedTime<int>(duration: k10ms * 3);

      var buffer = <int>[];

      beacon
        ..subscribe((value) => buffer = value)
        ..add(1)
        ..add(2)
        ..reset();

      await delay(k10ms * 4);

      expect(beacon.currentBuffer.value, equals([]));
      expect(buffer, equals([]));
    });
  });
}
