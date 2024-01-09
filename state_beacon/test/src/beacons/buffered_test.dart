import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  group('BufferedCountBeacon', () {
    test('should buffer values until count is reached', () {
      var beacon = Beacon.bufferedCount<int>(3);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);
      beacon.add(3); // This should trigger the buffer to be set

      expect(buffer, equals([1, 2, 3]));
    });

    test('should clear buffer after reaching count threshold', () {
      var beacon = Beacon.bufferedCount<int>(2);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2); // First trigger

      expect(buffer, equals([1, 2]));

      expect(beacon.currentBuffer.value, equals([]));

      beacon.add(3);

      expect(beacon.currentBuffer.value, equals([3]));

      beacon.add(4); // Second trigger

      expect(buffer, equals([3, 4]));
    });

    test('should update currentBuffer', () {
      var beacon = Beacon.bufferedCount<int>(3);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      expect(beacon.currentBuffer.value, equals([1, 2]));

      beacon.add(3); // This should trigger the buffer to be set
      beacon.add(4);

      expect(beacon.currentBuffer.value, equals([4]));

      expect(buffer, equals([1, 2, 3]));
    });

    test('should reset', () {
      var beacon = Beacon.bufferedCount<int>(3);
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      beacon.reset();

      expect(beacon.currentBuffer.value, equals([]));
      expect(buffer, equals([]));
    });
  });

  group('BufferedTimeBeacon', () {
    test('should buffer values over a time duration', () async {
      var beacon =
          Beacon.bufferedTime<int>(duration: Duration(milliseconds: 50));
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      await Future<void>.delayed(Duration(milliseconds: 10));

      expect(buffer, equals([]));

      await Future<void>.delayed(Duration(milliseconds: 50));

      expect(buffer, equals([1, 2]));
    });

    test('should reset buffer after time duration', () async {
      var beacon =
          Beacon.bufferedTime<int>(duration: Duration(milliseconds: 30));
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);
      beacon.add(3);
      beacon.add(4);

      await Future<void>.delayed(Duration(milliseconds: 40));

      expect(beacon.currentBuffer.value, equals([]));

      expect(buffer, equals([1, 2, 3, 4]));
    });

    test('should reset', () async {
      var beacon =
          Beacon.bufferedTime<int>(duration: Duration(milliseconds: 30));
      var buffer = [];
      beacon.subscribe((value) => buffer = value);

      beacon.add(1);
      beacon.add(2);

      beacon.reset();

      await Future<void>.delayed(Duration(milliseconds: 40));

      expect(beacon.currentBuffer.value, equals([]));
      expect(buffer, equals([]));
    });
  });
}
