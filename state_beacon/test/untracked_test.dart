import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should not send notification when doing untracked updates', () {
    final age = Beacon.writable<int>(10);
    var callCount = 0;

    Beacon.createEffect(() {
      age.value;
      callCount++;
      Beacon.untracked(() {
        age.value = 15;
      });
    });

    expect(callCount, equals(1));
    expect(age.value, 15);

    age.value = 20;
    expect(callCount, equals(2));
  });

  test('should not send notification when doing nested untracked updates', () {
    final age = Beacon.writable<int>(10);
    var callCount = 0;

    Beacon.createEffect(() {
      age.value;
      callCount++;
      Beacon.untracked(() {
        age.value = 15;
        Beacon.untracked(() {
          age.value = 20;
        });
      });
    });

    expect(callCount, equals(1));
    expect(age.value, 20);

    age.value = 25;
    expect(callCount, equals(2));
  });

  test('should not send notification when doing untracked access', () {
    final age = Beacon.writable<int>(10);
    final name = Beacon.writable<String>('John');

    var callCount = 0;

    Beacon.createEffect(() {
      age.value;
      callCount++;
      Beacon.untracked(() {
        name.value;
      });
    });

    expect(callCount, equals(1));

    age.value = 20;
    expect(callCount, equals(2));

    name.value = 'Jane';
    expect(callCount, equals(2));
  });
}
