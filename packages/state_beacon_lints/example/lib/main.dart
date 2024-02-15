import 'package:state_beacon/state_beacon.dart';

void main() {
  print('hello world');
}

class Main {}

const k10ms = Duration(milliseconds: 10);

final nameBeacon = Beacon.writable('Bob');
final ageBeacon = Beacon.writable(20);
final speedBeacon = Beacon.writable(10);

final nameFB = Beacon.future(() async => nameBeacon.value);
final ageFB = Beacon.future(() async {
  final age = ageBeacon.value; // <-- this is good
  print(ageBeacon.value);
  final dur = Duration(seconds: ageBeacon.value - 1);

  // expect_lint: avoid_value_access_after_await
  final name = await nameFB.toFuture();
  final nameStr = nameFB.toString();
  await Future<void>.delayed(k10ms);

  await Future<void>.delayed(
    // expect_lint: avoid_value_access_after_await
    k10ms * ageBeacon() * ageBeacon.value * ageBeacon.call(),
  );
  return '$name is $age years old  $dur $nameStr';
});

final speedFB = Beacon.future(() async {
  await Future<void>.delayed(k10ms);
  // expect_lint: avoid_value_access_after_await
  return speedBeacon.value; // <-- this is bad! should show a linter warning
});
