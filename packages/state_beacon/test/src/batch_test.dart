import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should send 1 notification when doing batch updates', () {
    final age = Beacon.writable<int>(10);
    var callCount = 0;
    age.subscribe((_) => callCount++);

    Beacon.batch(() {
      age.value = 15;
      age.value = 16;
      age.value = 20;
      age.value = 23;
    });

    // There were 4 updates, but only 1 notification
    expect(callCount, equals(1));
  });

  test('should not break beacon state when exception is thrown', () {
    final age = Beacon.writable<int>(10);
    var callCount = 0;
    age.subscribe((_) => callCount++);

    expect(
      () => Beacon.batch(() {
        age.value = 15;
        age.value = 16;
        age.value = 20;
        age.value = 23;
        throw Exception('Something went wrong');
      }),
      throwsException,
    );

    expect(callCount, equals(0));

    // this should still work
    age.increment();

    expect(callCount, equals(1));
  });

  test('should only notify once for nested batched updates', () {
    final age = Beacon.writable<int>(10);
    var callCount = 0;
    age.subscribe((_) => callCount++);

    Beacon.batch(() {
      age.value = 15;
      age.value = 16;
      Beacon.batch(() {
        age.value = 50;
        age.value = 51;
        Beacon.batch(() {
          age.value = 100;
          age.value = 200;
        });
        age.value = 52;
      });
      age.value = 20;
    });

    // There were 6 updates, but only 1 notification
    expect(callCount, equals(1));

    // The last value should be the one that was set last
    expect(age.value, equals(20));
  });
}
