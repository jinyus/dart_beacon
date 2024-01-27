// ignore_for_file: strict_raw_type

import 'package:state_beacon_core/src/base_beacon.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  test('should re-run when dependency changes', () async {
    final count = Beacon.writable(0);

    var ran = 0;

    Beacon.derivedFuture(() async {
      count.value;
      return ++ran;
    });

    await Future<void>.delayed(k1ms);

    expect(ran, 1);

    count.value = 1; // Changing dependency

    await Future<void>.delayed(k1ms);

    expect(ran, 2);
  });

  test('should clean up internal status beacon when disposed', () async {
    final count = Beacon.writable(0);

    final plus1 = Beacon.derivedFuture(
      () async => count.value + 1,
      manualStart: true,
    );

    final plus1Status = (plus1 as DerivedFutureBeacon).status;

    expect(plus1Status.value, DerivedFutureStatus.idle);

    plus1.start();

    await Future<void>.delayed(k1ms);

    expect(plus1.unwrapValue(), 1);

    expect(plus1Status.value, DerivedFutureStatus.running);

    plus1.dispose();

    expect(plus1Status.value, DerivedFutureStatus.idle);
    expect(plus1Status.isDisposed, isTrue);
  });

  test('should await FutureBeacon exposed a future', () async {
    final count = Beacon.writable(0);
    final count2 = Beacon.writable(0);

    final firstName = Beacon.derivedFuture(() async {
      final val = count.value;
      await Future<void>.delayed(k10ms);
      return 'Sally $val';
    });

    final lastName = Beacon.derivedFuture(() async {
      final val = count2.value + 1;
      await Future<void>.delayed(k10ms);
      return 'Smith $val';
    });

    final fullName = Beacon.derivedFuture(() async {
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

    await Future<void>.delayed(k10ms * 2);

    expect(fullName.value.unwrap(), 'Sally 0 Smith 1');

    count.increment();

    expect(fullName.value, isA<AsyncLoading>());

    await Future<void>.delayed(k10ms * 3);

    expect(fullName.value.unwrap(), 'Sally 1 Smith 1');

    count2.increment();

    expect(fullName.value, isA<AsyncLoading>());

    await Future<void>.delayed(k10ms * 3);

    expect(fullName.value.unwrap(), 'Sally 1 Smith 2');
  });

  test('should return error when dependency throws error', () async {
    final count = Beacon.writable(0);

    final firstName = Beacon.derivedFuture(() async {
      final val = count.value;
      await Future<void>.delayed(k10ms);
      if (val > 0) {
        throw Exception('error');
      }
      return 'Sally $val';
    });

    final greeting = Beacon.derivedFuture(() async {
      final fname = await firstName.toFuture();

      return 'Hello $fname';
    });

    expect(greeting.value, isA<AsyncLoading>());

    await Future<void>.delayed(k10ms * 1.1);

    expect(greeting.value.unwrap(), 'Hello Sally 0');

    count.increment();

    expect(greeting.value, isA<AsyncLoading>());

    await Future<void>.delayed(k10ms * 3);

    expect(greeting.value, isA<AsyncError>());
  });

  test('should not execute until start() is called', () async {
    final count = Beacon.writable(0);

    var ran = 0;

    final futureBeacon = Beacon.derivedFuture(
      () async {
        count.value;
        return ++ran;
      },
      manualStart: true,
    );

    await Future<void>.delayed(k10ms);

    expect(ran, 0);

    futureBeacon.start();

    await Future<void>.delayed(k10ms);

    expect(ran, 1);

    count.value = 1; // Changing dependency

    await Future<void>.delayed(k10ms);

    expect(ran, 2);

    futureBeacon.reset();

    await Future<void>.delayed(k10ms);

    expect(ran, equals(3));
  });
  test('should await StreamBeacon exposed a future', () async {
    Stream<int> idChanges() async* {
      yield 1;
      await Future<void>.delayed(k10ms);
      yield 2;
      await Future<void>.delayed(k10ms);
      yield 3;
    }

    Future<String> fetchUser(int id) async {
      await Future<void>.delayed(k10ms);
      return 'User $id';
    }

    final id = Beacon.stream(idChanges());
    final user = Beacon.derivedFuture(
      () async => fetchUser(await id.toFuture()),
    );

    final results = <AsyncValue<String>>[];
    final correctResults = [
      AsyncLoading<String>(),
      AsyncData('User 1'),
      AsyncLoading<String>(),
      AsyncData('User 2'),
      AsyncLoading<String>(),
      AsyncData('User 3'),
    ];

    Beacon.effect(() {
      results.add(user.value);
    });

    await Future<void>.delayed(const Duration(seconds: 1));

    expect(results, correctResults);
  });

  test('should trigger rerun when accessed before async gap', () async {
    final count = Beacon.writable<int>(3);

    late final nums = Beacon.derived(
      () => List.generate(count.value, (i) => i),
    );

    expect(nums.value, equals([0, 1, 2]));

    final numsDoubled = Beacon.derivedFuture(() async {
      // This will trigger a rerun because it is accessed before await
      final currentNums = nums.value;
      await Future<void>.delayed(k10ms);
      return currentNums.map((e) => e * 2).toList();
    });

    await Future<void>.delayed(k10ms * 2);

    expect(numsDoubled.value.unwrap(), equals([0, 2, 4]));

    count.value = 5;

    expect(nums.value, equals([0, 1, 2, 3, 4]));

    await Future<void>.delayed(k10ms * 2);

    expect(numsDoubled.value.unwrap(), equals([0, 2, 4, 6, 8]));
  });

  test('should work with multiple futurebeacon dependencies', () async {
    final nameBeacon = Beacon.writable('Bob');
    final ageBeacon = Beacon.writable(20);
    final speedBeacon = Beacon.writable(10);

    final nameFB = Beacon.derivedFuture(() async => nameBeacon());
    final ageFB = Beacon.derivedFuture(() async => ageBeacon());
    final speedFB = Beacon.derivedFuture(() async {
      final val = speedBeacon();
      await Future<void>.delayed(k10ms);
      return val;
    });

    final stats = Beacon.derivedFuture(() async {
      final nameFt = nameFB.toFuture();
      final ageFt = ageFB.toFuture();
      final speedFt = speedFB.toFuture();

      final (name, age, speed) = await (nameFt, ageFt, speedFt).wait;

      return '$name is $age years old and runs at $speed mph';
    });

    expect(stats.isLoading, isTrue);

    await Future<void>.delayed(k10ms * 2);

    expect(stats.unwrapValue(), 'Bob is 20 years old and runs at 10 mph');

    Beacon.batch(() {
      nameBeacon.value = 'Sally';
      ageBeacon.value = 21;
      speedBeacon.value = 11;
    });

    expect(stats.isLoading, isTrue);

    await Future<void>.delayed(k10ms * 2);

    expect(stats.unwrapValue(), 'Sally is 21 years old and runs at 11 mph');

    // override nameFB with error

    nameFB.overrideWith(() => throw Exception('error'));

    expect(stats.isLoading, isTrue);

    await Future<void>.delayed(k10ms * 2);

    expect(stats.isError, isTrue);
  });

  test('should not watch new beacon conditionally', () async {
    final num1 = Beacon.writable<int>(10);
    final num2 = Beacon.writable<int>(20);

    final derivedBeacon = Beacon.derivedFuture(
      () async {
        if (num2().isEven) return num2();
        return num1.value + num2.value;
      },
      supportConditional: false,
      manualStart: true,
    );

    expect(derivedBeacon(), isA<AsyncIdle>());

    derivedBeacon.start();

    expect(derivedBeacon.isLoading, true);

    await Future<void>.delayed(k10ms);

    expect(derivedBeacon.unwrapValue(), 20);

    num2.increment();

    expect(derivedBeacon.isLoading, true);

    await Future<void>.delayed(k10ms);

    expect(derivedBeacon.unwrapValue(), 31);

    // should not trigger recompute as it wasn't accessed on first run
    num1.value = 15;

    expect(derivedBeacon.isLoading, false);

    expect(derivedBeacon.unwrapValue(), 31);
  });

  test('should stop watching dependencies when it has no more watchers',
      () async {
    final num1 = Beacon.writable<int>(10, name: 'num1');
    final num2 = Beacon.writable<int>(20, name: 'num2');

    final derivedBeacon = Beacon.derivedFuture(
      () async => num1.value + num2.value,
      name: 'derived',
    );

    final status = (derivedBeacon as DerivedFutureBeacon).status;

    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);
    expect(derivedBeacon.listenersCount, 0);

    final unsub = Beacon.effect(
      () => derivedBeacon.value,
      name: 'custom effect',
    );

    expect(derivedBeacon.listenersCount, 1);

    expect(
      status.value,
      DerivedFutureStatus.running,
    );

    unsub();

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 0);

    // should start listening again when value is accessed
    num1.value = 15;

    expect(status.value, DerivedFutureStatus.idle);

    expect(derivedBeacon.isLoading, true);

    await Future<void>.delayed(k1ms);

    expect(derivedBeacon.unwrapValue(), 35);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);

    // should stop listening again when it has no more listeners

    final unsub2 = Beacon.effect(() => derivedBeacon.value);

    expect(derivedBeacon.listenersCount, 1);

    expect(status.value, DerivedFutureStatus.running);

    unsub2();

    expect(status.value, DerivedFutureStatus.idle);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 0);
    expect(num2.listenersCount, 0);

    // should start listening again when value is accessed
    num1.value = 20;

    expect(derivedBeacon.value.isLoading, true);

    await Future<void>.delayed(k1ms);

    expect(derivedBeacon.peek().unwrap(), 40);

    expect(derivedBeacon.listenersCount, 0);
    expect(num1.listenersCount, 1);
    expect(num2.listenersCount, 1);
  });

  test('should not run when it has no more watchers', () async {
    final num1 = Beacon.writable<int>(10);
    final num2 = Beacon.writable<int>(20);
    var ran = 0;

    final derivedBeacon = Beacon.derivedFuture(() async {
      ran++;
      return num1.value + num2.value;
    });

    expect(ran, 1);

    final unsub = Beacon.effect(() => derivedBeacon.value);

    expect(ran, 1);

    num1.increment();

    await Future<void>.delayed(k1ms);

    expect(ran, 2);

    unsub();

    // derived should not execute when it has no more watchers
    num1.increment();
    num2.increment();

    expect(ran, 2);

    expect(derivedBeacon.isLoading, true);

    expect(ran, 3);

    num1.increment();

    expect(ran, 4);

    await Future<void>.delayed(k1ms);

    expect(derivedBeacon.unwrapValue(), 34);

    expect(ran, 4);
  });
}
