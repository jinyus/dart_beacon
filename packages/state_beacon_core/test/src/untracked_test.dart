import 'package:test/test.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

void main() {
  test('should not send notification when doing untracked updates', () {
    final age = Beacon.writable<int>(10);
    var callCount = 0;

    Beacon.effect(() {
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
    var subCallCount = 0;

    age.subscribe((p0) {
      subCallCount++;
    });

    Beacon.effect(() {
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
    expect(subCallCount, equals(2));
    expect(age.value, 20);

    age.value = 25;
    expect(callCount, equals(2));

    // this is 5 and not 3 because the effect runs when 25 is set
    // so the 2 untracked blocks will execute and change the value to 15 then 20
    expect(subCallCount, equals(5));
  });

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

    expect(callCount, equals(1));

    age.value = 20;
    expect(callCount, equals(2));

    name.value = 'Jane';
    expect(callCount, equals(2));
  });
}
