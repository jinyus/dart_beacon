import 'package:state_beacon_core/src/producer.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

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

    BeaconScheduler.flush();

    expect(callCount, equals(1));
    expect(age.value, 15);

    age.value = 20;

    BeaconScheduler.flush();

    expect(callCount, equals(2));
  });

  test('should notify other consumers', () {
    final age = Beacon.writable<int>(10);
    var ran = 0;
    var ran2 = 0;

    Beacon.effect(() {
      age.value;
      ran++;
      Beacon.untracked(() {
        age.value = 30;
        Beacon.untracked(() {
          age.value = 35;
        });
      });
    });

    age.subscribe((_) => ran2++);

    BeaconScheduler.flush();

    expect(ran, 1);
    expect(ran2, 1);
    expect(age.value, 35);

    // BeaconObserver.instance = LoggingObserver();

    age.value = 20;

    BeaconScheduler.flush();

    expect(ran, 2);

    if (isSynchronousMode) {
      // this is because when "a" changes to 20, the effect will run first
      // which changes the value to 35, then the subscription will run
      // with a value of 35
      expect(ran2, 2);
    } else {
      // when "a" changes to 20, both the effect and the subscription
      // will be scheduled and both runs with a value of 20. When the effect
      // runs, the mutation to 35 will schedule the subscription to run again
      expect(ran2, 3);
    }
  });

  test('should not send notification when doing untracked access', () {
    final age = Beacon.writable<int>(10);
    final name = Beacon.writable<String>('John');

    var callCount = 0;

    Beacon.effect(() {
      age.value;
      callCount++;
      name.peek();
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
