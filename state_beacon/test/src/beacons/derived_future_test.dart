import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/src/base_beacon.dart';
import 'package:state_beacon/state_beacon.dart';

import '../../common.dart';

void main() {
  test('should re-initializes when dependency changes', () async {
    var count = Beacon.writable(0);

    var ran = 0;

    var _ = Beacon.derivedFuture(() async {
      count.value;
      return ++ran;
    });

    await Future.delayed(Duration(milliseconds: 10));

    expect(ran, equals(1));

    count.value = 1; // Changing dependency

    await Future.delayed(Duration(milliseconds: 10));

    expect(ran, equals(2));
  });

  test('should clean up internal status beacon when disposed', () async {
    var count = Beacon.writable(0);

    var plus1 = Beacon.derivedFuture(() async {
      return count.value + 1;
    }, manualStart: true);

    final plus1Status = (plus1 as DerivedFutureBeacon).status;

    expect(plus1Status.value, DerivedFutureStatus.idle);

    plus1.start();

    await Future.delayed(k10ms);

    expect(plus1.value.unwrapValue(), equals(1));

    expect(plus1Status.value, DerivedFutureStatus.running);

    plus1.dispose();

    expect(plus1Status.value, DerivedFutureStatus.idle);
  });

  test('should await FutureBeacon exposed a future', () async {
    var count = Beacon.writable(0);
    var count2 = Beacon.writable(0);

    var firstName = Beacon.derivedFuture(() async {
      final val = count.value;
      await Future.delayed(k10ms);
      return 'Sally $val';
    });

    var lastName = Beacon.derivedFuture(() async {
      final val = count2.value + 1;
      await Future.delayed(k10ms);
      return 'Smith $val';
    });

    var fullName = Beacon.derivedFuture(() async {
      // final fname = await firstName.toFuture();

      // a change in this won't trigger a rerun because of the async gap
      // only values accessed before await will trigger a rerun
      // so Future.wait must be used to ensure both futures are accessed
      // final lname = await lastName.toFuture();

      final [fname, lname] = await Future.wait(
        [
          firstName.toFuture(),
          lastName.toFuture(),
        ],
      );

      final name = '$fname $lname';

      return name;
    });

    expect(fullName.value, isA<AsyncLoading>());

    await Future.delayed(k10ms * 2);

    expect(fullName.value.unwrapValue(), 'Sally 0 Smith 1');

    count.increment();

    expect(fullName.value, isA<AsyncLoading>());

    await Future.delayed(k10ms * 3);

    expect(fullName.value.unwrapValue(), 'Sally 1 Smith 1');

    count2.increment();

    expect(fullName.value, isA<AsyncLoading>());

    await Future.delayed(k10ms * 3);

    expect(fullName.value.unwrapValue(), 'Sally 1 Smith 2');
  });

  test('should return error when dependency throws error', () async {
    var count = Beacon.writable(0);

    var firstName = Beacon.derivedFuture(() async {
      final val = count.value;
      await Future.delayed(k10ms);
      if (val > 0) {
        throw Exception('error');
      }
      return 'Sally $val';
    });

    var greeting = Beacon.derivedFuture(() async {
      final fname = await firstName.toFuture();

      return 'Hello $fname';
    });

    expect(greeting.value, isA<AsyncLoading>());

    await Future.delayed(k10ms * 1.1);

    expect(greeting.value.unwrapValue(), 'Hello Sally 0');

    count.increment();

    expect(greeting.value, isA<AsyncLoading>());

    await Future.delayed(k10ms * 3);

    expect(greeting.value, isA<AsyncError>());
  });

  test('should not execute until start() is called', () async {
    var count = Beacon.writable(0);

    var ran = 0;

    var futureBeacon = Beacon.derivedFuture(() async {
      count.value;
      return ++ran;
    }, manualStart: true);

    await Future.delayed(Duration(milliseconds: 10));

    expect(ran, equals(0));

    futureBeacon.start();

    await Future.delayed(Duration(milliseconds: 10));

    expect(ran, equals(1));

    count.value = 1; // Changing dependency

    await Future.delayed(Duration(milliseconds: 10));

    expect(ran, equals(2));

    futureBeacon.reset();

    await Future.delayed(Duration(milliseconds: 10));

    expect(ran, equals(3));
  });
  test('should await StreamBeacon exposed a future', () async {
    Stream<int> idChanges() async* {
      yield 1;
      await Future.delayed(k10ms);
      yield 2;
      await Future.delayed(k10ms);
      yield 3;
    }

    Future<String> fetchUser(int id) async {
      await Future.delayed(k10ms);
      return 'User $id';
    }

    final id = Beacon.stream(idChanges());
    final user = Beacon.derivedFuture(() async {
      return fetchUser(await id.toFuture());
    });

    final results = <AsyncValue>[];
    final correctResults = [
      AsyncLoading<String>(),
      AsyncData('User 1'),
      AsyncLoading<String>(),
      AsyncData('User 2'),
      AsyncLoading<String>(),
      AsyncData('User 3'),
    ];

    Beacon.createEffect(() {
      results.add(user.value);
    });

    await Future.delayed(const Duration(seconds: 1));

    expect(results, correctResults);
  });
}
