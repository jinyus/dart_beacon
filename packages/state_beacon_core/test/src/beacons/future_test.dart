import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

Future<int> testFuture(bool crash) async {
  if (crash) {
    throw Exception('error');
  }
  return 1;
}

void main() {
  test('should change to AsyncData on successful future resolution', () async {
    final completer = Completer<String>();
    final futureBeacon = Beacon.future(() async => completer.future, name: 'f');

    expect(futureBeacon.isLoading, true);

    completer.complete('result');
    await completer.future; // Wait for the future to complete

    await BeaconScheduler.settle();

    expect(futureBeacon.value, isA<AsyncData<String>>());

    expect(futureBeacon.unwrapValue(), 'result');
  });

  test('should change to AsyncError on future error', () async {
    final futureBeacon = Beacon.future<String>(
      () async => throw Exception('error'),
    );

    expect(futureBeacon.isLoading, true);

    await delay(k10ms);

    expect(futureBeacon.isError, true);

    final error = futureBeacon.value as AsyncError;

    expect(error.error, isA<Exception>());
  });

  test('should set initial state to AsyncLoading', () {
    final futureBeacon = Beacon.future(() async => 'result');
    expect(futureBeacon.isLoading, true);
    expect(futureBeacon.isIdleOrLoading, true);
  });

  test('should re-executes the future on reset', () async {
    var counter = 0;

    final futureBeacon = Beacon.future(() async => ++counter, name: 'f');

    expect(futureBeacon.isLoading, true);

    await delay(k1ms);

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.reset();

    expect(futureBeacon.isLoading, true);

    await delay(k1ms);

    expect(futureBeacon.isData, isTrue);

    expect(futureBeacon.unwrapValue(), 2);
  });

  test('should not executes until start() is called', () async {
    var counter = 0;

    final futureBeacon = Beacon.future(
      () async => ++counter,
      manualStart: true,
    );

    expect(futureBeacon.isIdle, true);

    await delay(k1ms);

    expect(counter, 0);

    futureBeacon.start();

    expect(futureBeacon.isLoading, true);

    await delay(k1ms);

    expect(futureBeacon.isData, isTrue);

    expect(futureBeacon.unwrapValue(), equals(1));
  });

  test('should override internal function', () async {
    final futureBeacon = Beacon.future(() async => testFuture(false));

    expect(futureBeacon.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.overrideWith(() async => testFuture(true));

    expect(futureBeacon.value.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.isError, isTrue);
  });

  test('should set last data in loading and error states', () async {
    final controller = StreamController<int>.broadcast();

    final myBeacon = Beacon.future(() => controller.stream.first, name: 'f');

    await BeaconScheduler.settle();

    expect(myBeacon.isLoading, true);

    controller.add(10);

    await BeaconScheduler.settle();

    expect(myBeacon.unwrapValue(), 10);

    myBeacon.overrideWith(() => controller.stream.first);

    await BeaconScheduler.settle();

    expect(myBeacon.isLoading, true);

    expect(myBeacon.lastData, 10);

    controller.addError(Exception('error'));

    await BeaconScheduler.settle();

    expect(myBeacon.isError, true);

    expect(myBeacon.lastData, 10);
  });

  test('should re-run when dependency changes', () async {
    final count = Beacon.writable(0);

    var ran = 0;

    Beacon.future(() async {
      count.value;
      return ++ran;
    });

    await delay(k1ms);

    expect(ran, 1);

    count.value = 1; // Changing dependency

    await delay(k1ms);

    expect(ran, 2);
  });

  test('should clean up internal status beacon when disposed', () async {
    final count = Beacon.writable(0);

    final plus1 = Beacon.future(
      () async => count.value + 1,
      manualStart: true,
    );

    final plus1Status = plus1.status;

    expect(plus1Status.value, FutureStatus.idle);

    plus1.start();

    await delay(k1ms);

    expect(plus1.unwrapValue(), 1);

    expect(plus1Status.value, FutureStatus.running);

    plus1.dispose();

    expect(plus1Status.peek(), FutureStatus.idle);
    expect(plus1Status.isDisposed, isTrue);
  });

  test('should await FutureBeacon exposed a future', () async {
    final count = Beacon.writable(0, name: 'count');
    final count2 = Beacon.writable(0, name: 'count2');

    final firstName = Beacon.future(
      () async {
        final val = count.value;
        await delay(k10ms);
        return 'Sally $val';
      },
      name: 'firstName',
    );

    final lastName = Beacon.future(
      () async {
        final val = count2.value + 1;
        await delay(k10ms);
        return 'Smith $val';
      },
      name: 'lastName',
    );

    final fullName = Beacon.future(
      () async {
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
      },
      name: 'fullName',
    );

    expect(fullName.value, isA<AsyncLoading<String>>());

    await delay(k10ms * 2);

    expect(fullName.unwrapValue(), 'Sally 0 Smith 1');

    count.increment();

    await BeaconScheduler.settle();

    expect(fullName.isLoading, true);

    await delay(k10ms * 3);

    expect(fullName.value.unwrap(), 'Sally 1 Smith 1');

    count2.increment();

    await BeaconScheduler.settle();

    expect(fullName.isLoading, true);

    await delay(k10ms * 3);

    expect(fullName.value.unwrap(), 'Sally 1 Smith 2');
  });

  test('should return error when callback throws error', () async {
    final count = Beacon.writable(0);

    final firstName = Beacon.future(() async {
      final val = count.value;
      await delay(k1ms);
      if (val > 0) {
        throw Exception('error');
      }
      return 'Sally $val';
    });

    final greeting = Beacon.future(() async {
      final fname = await firstName.toFuture();

      return 'Hello $fname';
    });

    expect(greeting.isLoading, true);

    await delay(k10ms * 1.1);

    expect(greeting.value.unwrap(), 'Hello Sally 0');

    count.increment();

    await BeaconScheduler.settle();

    expect(greeting.isLoading, true);

    await delay(k10ms * 3);

    expect(greeting.isError, true);
  });

  test('should not execute until start() is called', () async {
    final count = Beacon.writable(0);

    var ran = 0;

    final futureBeacon = Beacon.future(
      () async {
        count.value;
        return ++ran;
      },
      manualStart: true,
    );

    await delay(k10ms);

    expect(ran, 0);

    futureBeacon.start();

    await delay(k10ms);

    expect(ran, 1);

    count.value = 1; // Changing dependency

    await delay(k10ms);

    expect(ran, 2);

    futureBeacon.reset();

    await delay(k10ms);

    expect(ran, equals(3));
  });

  test('should await StreamBeacon exposed a future', () async {
    Stream<int> idChanges() async* {
      yield 1;
      await delay(k10ms);
      yield 2;
      await delay(k10ms);
      yield 3;
    }

    Future<String> fetchUser(int id) async {
      return 'User $id';
    }

    final id = Beacon.stream(idChanges, name: 'id');
    final user = Beacon.future(
      () async => fetchUser(await id.toFuture()),
      name: 'user',
    );

    final correctResults = [
      AsyncLoading<String>(),
      AsyncData('User 1'),
      AsyncLoading<String>(),
      AsyncData('User 2'),
      AsyncLoading<String>(),
      AsyncData('User 3'),
    ];

    final buff = user.buffer(6, name: 'buff');

    final result = await buff.next();

    expect(result, correctResults);

    id.dispose();

    expect(id.isDisposed, true);
  });

  test('should trigger rerun when accessed before async gap', () async {
    final count = Beacon.writable<int>(3);

    late final nums = Beacon.derived(
      () => List.generate(count.value, (i) => i),
    );

    expect(nums.value, equals([0, 1, 2]));

    final numsDoubled = Beacon.future(() async {
      // This will trigger a rerun because it is accessed before await
      final currentNums = nums.value;
      await delay(k10ms);
      return currentNums.map((e) => e * 2).toList();
    });

    await delay(k10ms * 2);

    expect(numsDoubled.value.unwrap(), equals([0, 2, 4]));

    count.value = 5;

    expect(nums.value, equals([0, 1, 2, 3, 4]));

    await delay(k10ms * 2);

    expect(numsDoubled.value.unwrap(), equals([0, 2, 4, 6, 8]));
  });

  test('should work with multiple futurebeacon dependencies', () async {
    final nameBeacon = Beacon.writable('Bob', name: 'name');
    final ageBeacon = Beacon.writable(20, name: 'age');
    final speedBeacon = Beacon.writable(10, name: 'speed');

    final nameFB = Beacon.future(() async => nameBeacon(), name: 'nameFB');
    final ageFB = Beacon.future(() async => ageBeacon(), name: 'ageFB');
    final speedFB = Beacon.future(
      () async {
        final val = speedBeacon();
        await delay(k10ms);
        return val;
      },
      name: 'speedFB',
    );

    final stats = Beacon.future(
      () async {
        final nameFt = nameFB.toFuture();
        final ageFt = ageFB.toFuture();
        final speedFt = speedFB.toFuture();

        final (name, age, speed) = await (nameFt, ageFt, speedFt).wait;

        return '$name is $age years old and runs at $speed mph';
      },
      name: 'stats',
    );

    expect(stats.isLoading, isTrue);

    await delay(k10ms * 2);

    expect(stats.unwrapValue(), 'Bob is 20 years old and runs at 10 mph');

    nameBeacon.value = 'Sally';
    ageBeacon.value = 21;
    speedBeacon.value = 11;

    await BeaconScheduler.settle();

    expect(stats.isLoading, isTrue);

    await delay(k10ms * 2);

    expect(stats.unwrapValue(), 'Sally is 21 years old and runs at 11 mph');

    // override nameFB with error

    nameFB.overrideWith(() => throw Exception('error'));

    // await BeaconScheduler.settle();

    await expectLater(
      stats.stream,
      emitsInOrder([
        isA<AsyncData<String>>(),
        isA<AsyncLoading<String>>(),
        isA<AsyncError<String>>(),
      ]),
    );
  });

  test('should stop watching dependencies when it has no more watchers',
      () async {
    // BeaconObserver.instance = LoggingObserver();
    final num1 = Beacon.writable<int>(10, name: 'num1');
    final num2 = Beacon.writable<int>(20, name: 'num2');

    final derivedBeacon = Beacon.future(
      () async => num1.value + num2.value,
      name: 'derived',
    );

    final status = derivedBeacon.status;

    await BeaconScheduler.settle();

    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);
    expect(derivedBeacon.listenersCount, 0);

    final unsub = Beacon.effect(
      () => derivedBeacon.value,
      name: 'custom effect',
    );

    await BeaconScheduler.settle();

    expect(derivedBeacon.listenersCount, 1);

    expect(
      status.value,
      FutureStatus.running,
    );

    unsub();

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 0);

    // should start listening again when value is accessed
    num1.value = 15;

    expect(status.value, FutureStatus.idle);

    expect(derivedBeacon.isLoading, true);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 35);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    // should stop listening again when it has no more listeners

    final unsub2 = Beacon.effect(() => derivedBeacon.value);

    await BeaconScheduler.settle();

    expect(derivedBeacon.listenersCount, 1);

    expect(status.value, FutureStatus.running);

    unsub2();

    expect(status.value, FutureStatus.idle);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 0);

    // should start listening again when value is accessed
    num1.value = 20;

    expect(derivedBeacon.value.isLoading, true);

    await delay(k1ms);

    expect(derivedBeacon.peek().unwrap(), 40);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);
  });

  test('should not run when it has no more watchers', () async {
    final num1 = Beacon.writable<int>(10);
    final num2 = Beacon.writable<int>(20);
    var ran = 0;

    final derivedBeacon = Beacon.future(() async {
      ran++;
      return num1.value + num2.value;
    });

    await BeaconScheduler.settle();

    expect(ran, 1);

    final unsub = Beacon.effect(() => derivedBeacon.value);

    await BeaconScheduler.settle();

    expect(ran, 1);

    num1.increment();

    await delay(k1ms);

    expect(ran, 2);

    unsub();

    // derived should not execute when it has no more watchers
    num1.increment();
    num2.increment();

    await BeaconScheduler.settle();

    expect(ran, 2);

    expect(derivedBeacon.isLoading, true);

    await BeaconScheduler.settle();

    expect(ran, 3);

    num1.increment();

    await BeaconScheduler.settle();

    expect(ran, 4);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 34);

    expect(ran, 4);
  });

  test('should run when it has no more watchers when shouldSleep=false',
      () async {
    final num1 = Beacon.writable<int>(10);
    final num2 = Beacon.writable<int>(20);
    var ran = 0;

    final derivedBeacon = Beacon.future(
      () async {
        ran++;
        return num1.value + num2.value;
      },
      shouldSleep: false,
    );

    await BeaconScheduler.settle();

    expect(ran, 1);

    final unsub = Beacon.effect(() => derivedBeacon.value);

    expect(ran, 1);

    num1.increment();

    await delay(k1ms);

    expect(ran, 2);

    unsub();

    // derived should still execute when it has no more watchers
    num1.increment();

    await BeaconScheduler.settle();

    num2.increment();

    await BeaconScheduler.settle();

    expect(ran, 4);

    num1.increment();

    await BeaconScheduler.settle();

    expect(ran, 5);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 34);

    expect(ran, 5);
  });

  test('should conditionally stop listening to dependencies', () async {
    final num1 = Beacon.writable<int>(10, name: 'num1');
    final num2 = Beacon.writable<int>(10, name: 'num2');
    final num3 = Beacon.writable<int>(10, name: 'num3');
    final guard = Beacon.writable<bool>(true, name: 'guard');

    final derivedBeacon = Beacon.future(
      () async {
        if (guard.value) return num1.value;

        return num2.value + num3.value;
      },
      name: 'derived',
      shouldSleep: false,
    );

    await BeaconScheduler.settle();

    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 0);
    expect(num3.listenersCount, 0);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 10);

    num1.increment();

    await expectLater(
      derivedBeacon.stream,
      emitsInOrder([
        isA<AsyncLoading<int>>(),
        AsyncData<int>(11),
      ]),
    );

    guard.value = false;

    await BeaconScheduler.settle();

    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 1);
    expect(num3.listenersCount, 1);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 20);

    num1.increment();

    await BeaconScheduler.settle();

    expect(derivedBeacon.unwrapValue(), 20);

    num2.increment();

    await BeaconScheduler.settle();

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 21);

    guard.value = true;

    await BeaconScheduler.settle();

    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 0);
    expect(num3.listenersCount, 0);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 12);
  });

  test('should set last data in loading and error states', () async {
    final controller = StreamController<int>.broadcast();

    final count = Beacon.writable(10, name: 'count');

    final myBeacon = Beacon.future(
      () async {
        final a = count.value;
        final res = await controller.stream.first;
        return res * a;
      },
      name: 'myBeacon',
    );

    await BeaconScheduler.settle();

    expect(myBeacon.isLoading, true);

    controller.add(10);

    await BeaconScheduler.settle(k10ms);

    expect(myBeacon.unwrapValue(), 100);

    count.value = 20;

    await BeaconScheduler.settle();

    expect(myBeacon.isLoading, true);

    expect(myBeacon.lastData, 100);

    controller.addError(Exception('error'));

    await BeaconScheduler.settle();

    expect(myBeacon.isError, true);

    expect(myBeacon.lastData, 100);
  });
}
