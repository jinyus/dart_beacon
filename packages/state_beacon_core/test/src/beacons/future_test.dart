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

    await delay(k10ms);

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

    final futureBeacon = Beacon.future(
      () async {
        await delay(k1ms);
        return ++counter;
      },
      name: 'f',
    );

    expect(futureBeacon.isLoading, true);

    await delay();

    expect(futureBeacon.unwrapValue(), 1);

    futureBeacon.reset();

    BeaconScheduler.flush();

    expect(futureBeacon.isLoading, true);

    await delay();

    expect(futureBeacon.isData, isTrue);

    expect(futureBeacon.unwrapValue(), 2);
  });

  test('should not executes until start() is called', () async {
    var counter = 0;

    final futureBeacon = Beacon.future(
      () async {
        await delay(k1ms);
        return ++counter;
      },
      manualStart: true,
    );

    expect(futureBeacon.isIdle, true);

    await delay(k1ms);

    expect(counter, 0);

    futureBeacon.start();

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

    expect(futureBeacon.value.isLoading, isTrue);

    await delay(k1ms);

    expect(futureBeacon.isError, isTrue);
  });

  test('should set last data in loading and error states', () async {
    final controller = StreamController<int>.broadcast();

    final myBeacon = Beacon.future(() => controller.stream.first, name: 'f');

    BeaconScheduler.flush();

    expect(myBeacon.isLoading, true);

    controller.add(10);

    await delay(k10ms);

    expect(myBeacon.unwrapValue(), 10);

    myBeacon.overrideWith(() => controller.stream.first);

    BeaconScheduler.flush();

    expect(myBeacon.isLoading, true);

    expect(myBeacon.lastData, 10);

    controller.addError(Exception('error'));

    await delay(k10ms);

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

    BeaconScheduler.flush();

    expect(fullName.isLoading, true);

    await delay(k10ms * 3);

    expect(fullName.value.unwrap(), 'Sally 1 Smith 1');

    count2.increment();

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

    expect(stats.isLoading, isTrue);

    await delay(k10ms * 2);

    expect(stats.unwrapValue(), 'Sally is 21 years old and runs at 11 mph');

    // override nameFB with error

    nameFB.overrideWith(() async => throw Exception('error'));

    // BeaconScheduler.flush();

    await expectLater(
      stats.stream,
      emitsInOrder([
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

    BeaconScheduler.flush();

    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);
    expect(derivedBeacon.listenersCount, 0);

    final unsub = Beacon.effect(
      () => derivedBeacon.value,
      name: 'custom effect',
    );

    BeaconScheduler.flush();

    expect(derivedBeacon.listenersCount, 1);

    unsub();

    await delay();

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 0);

    // should start listening again when value is accessed
    num1.value = 15;

    expect(derivedBeacon.isLoading, true);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 35);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    // should stop listening again when it has no more listeners

    final unsub2 = Beacon.effect(() => derivedBeacon.value);

    BeaconScheduler.flush();

    expect(derivedBeacon.listenersCount, 1);

    unsub2();

    await delay();

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

    BeaconScheduler.flush();

    expect(ran, 1);

    final unsub = Beacon.effect(() => derivedBeacon.value);

    BeaconScheduler.flush();

    expect(ran, 1);

    num1.increment();

    await delay(k1ms);

    expect(ran, 2);

    unsub();

    await delay(k1ms);

    // derived should not execute when it has no more watchers
    num1.increment();
    num2.increment();

    BeaconScheduler.flush();

    expect(ran, 2);

    expect(derivedBeacon.isLoading, true);
    expect(derivedBeacon.unwrapValueOrNull(), null);

    BeaconScheduler.flush();

    expect(ran, 3);

    num1.increment();

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

    expect(ran, 1);

    final unsub = Beacon.effect(() => derivedBeacon.value);

    expect(ran, 1);

    num1.increment();

    await delay(k1ms);

    expect(ran, 2);

    unsub();

    // derived should still execute when it has no more watchers
    num1.increment();

    BeaconScheduler.flush();

    num2.increment();

    BeaconScheduler.flush();

    expect(ran, 4);

    num1.increment();

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

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

    BeaconScheduler.flush();

    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 1);
    expect(num3.listenersCount, 1);

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 20);

    num1.increment();

    BeaconScheduler.flush();

    expect(derivedBeacon.unwrapValue(), 20);

    num2.increment();

    BeaconScheduler.flush();

    await delay(k1ms);

    expect(derivedBeacon.unwrapValue(), 21);

    guard.value = true;

    BeaconScheduler.flush();

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

    await delay(k10ms);

    expect(myBeacon.isLoading, true);

    controller.add(10);

    await delay(k10ms);

    expect(myBeacon.unwrapValue(), 100);

    count.value = 20;

    await delay(k10ms);

    expect(myBeacon.isLoading, true);

    expect(myBeacon.lastData, 100);

    controller.addError(Exception('error'));

    await delay(k10ms);

    expect(myBeacon.isError, true);

    expect(myBeacon.lastData, 100);
  });

  test('should avoid race condition', () async {
    var delayMultiplier = 1;

    Future<int> sampleFuture() async {
      await delay(k10ms * delayMultiplier);
      return 1 * delayMultiplier;
    }

    final a = Beacon.writable(true);
    final b = Beacon.future(
      () async {
        a.value;
        final res = await sampleFuture();
        return res;
      },
    );

    expect(b.isLoading, true);
    BeaconScheduler.flush();
    expect(b.isLoading, true);
    a.toggle();
    delayMultiplier = 2;
    BeaconScheduler.flush();
    expect(b.isLoading, true);

    await delay(k10ms * 2);

    expect(b.unwrapValue(), 2);
  });

  test(
    'should run at most once when aync beacon dependency changes',
    () async {
      final a = Beacon.writable(0, name: 'a');
      final b = Beacon.writable(10, name: 'b');
      final fb1 = Beacon.future(() async => a.value + 10, name: 'fb1');
      final fb2 = Beacon.future(() async => b.value + 10, name: 'fb2');

      var ran = 0;

      final f3 = Beacon.future(
        () async {
          ran++;
          final f1 = fb1.toFuture();
          final f2 = fb2.toFuture();

          final (res1, res2) = await (f1, f2).wait;

          return res1 + res2;
        },
        name: 'f3',
      );

      expect(f3.isLoading, true);
      await delay(k10ms);
      expect(f3.unwrapValue(), 30);
      expect(ran, 1);

      // print('\nupdate a\n');
      a.increment();
      BeaconScheduler.flush();
      expect(f3.isLoading, true);
      await delay();
      expect(f3.unwrapValue(), 31);
      expect(ran, 2);

      // print('\nupdate b\n');
      b.increment();
      BeaconScheduler.flush();
      expect(f3.isLoading, true);
      await delay();
      expect(f3.unwrapValue(), 32);
      expect(ran, 3);
    },
  );

  test('should emit error when stream throws', () async {
    Stream<List<int>> getStream() async* {
      yield [1, 2, 3];
      await delay(k10ms);
      yield [4, 5, 6];
      await delay(k10ms);
      throw Exception('error');
    }

    final s = Beacon.stream(getStream, name: 's');

    final f = Beacon.future(
      () async {
        final res = await s.toFuture();
        return res;
      },
      name: 'f',
    );

    await expectLater(
      f.stream,
      emitsInOrder([
        isA<AsyncLoading<List<int>>>(),
        isA<AsyncData<List<int>>>(),
        isA<AsyncLoading<List<int>>>(),
        isA<AsyncData<List<int>>>(),
        isA<AsyncLoading<List<int>>>(),
        isA<AsyncError<List<int>>>(),
      ]),
    );
  });

  test('should ignore error when stream throws', () async {
    Stream<List<int>> getStream() async* {
      yield [1, 2, 3];
      await delay(k10ms);
      yield [4, 5, 6];
      await delay(k10ms);
      throw Exception('error');
    }

    // BeaconObserver.instance = LoggingObserver(includeNames: ['d', 'm']);

    final s = Beacon.stream(getStream, name: 's');

    final sFiltered = s
        .filter((_, n) => n.isData)
        .map((v) => v.unwrapOrNull() ?? [], name: 'm');

    final d = Beacon.derived(
      () {
        final res = sFiltered.value;
        return res;
      },
      name: 'd',
    );

    await expectLater(
      d.stream,
      emitsInOrder([
        <int>[],
        [1, 2, 3],
        [4, 5, 6],
      ]),
    );
  });
}
