import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

void main() {
  test('should notify listeners when value changes', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0);
    var called = 0;

    beacon.subscribe((_) => called++);
    beacon.value = 10;
    beacon.value = 11;

    expect(called, equals(2));
  });

  test('undo should revert to the previous value', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0);
    beacon.value = 10; // History: [0, 10]
    beacon.value = 20; // History: [0, 10, 20]

    beacon.undo();

    expect(beacon.value, 10);
  });

  test('redo should revert to the next value after undo', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0);
    beacon.value = 10; // History: [0, 10]
    beacon.value = 20; // History: [0, 10, 20]
    beacon.undo(); // History: [0, <10>, 20]

    beacon.redo(); // History: [0, 10, <20>]

    expect(beacon.value, 20);
  });

  test('should not undo beyond the initial value', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0);
    beacon.value = 10;
    beacon.undo(); // Should stay at initial value

    expect(beacon.value, 0);
  });

  test('should not redo beyond the latest value', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0);
    beacon.value = 10; // History: [0, 10]
    beacon.value = 20; // History: [0, 10, 20]
    beacon.undo(); // History: [0, <10>, 20]
    beacon.redo(); // History: [0, 10, <20>]
    beacon.redo(); // Should stay at latest value

    expect(beacon.value, 20);
  });

  test('should truncate future history if value is set after undo', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0);
    // Set initial values
    beacon.set(1);
    beacon.set(2);
    beacon.set(3); // History: [0, 1, 2, 3]

    // Undo twice, moving back in history
    beacon.undo(); // Current value is 2
    beacon.undo(); // Current value is 1

    // Set a new value after undo
    beacon.set(4); // New history should be [0, 1, 4]

    // Check the length of history and current value
    expect(beacon.value, equals(4));
    expect(beacon.history, equals([0, 1, 4]));
  });

  test('should respect history limit', () {
    final beacon = UndoRedoBeacon<int>(initialValue: 0, historyLimit: 2);
    beacon.value = 10; // History: [0, 10]
    beacon.value = 20; // History: [10, 20]
    beacon.value = 30; // History: [20, 30] (0 should be pushed out)

    beacon.undo();
    beacon.undo(); // Should not be able to undo to 0

    expect(beacon.value, 20);
  });
}
