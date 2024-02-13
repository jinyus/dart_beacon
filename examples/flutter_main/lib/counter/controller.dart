part of 'counter.dart';

Future<String> counterFuture(int count) async {
  if (count > 3) {
    throw Exception('Count($count) cannot be greater than 3');
  } else if (count < 0) {
    throw Exception('Count($count) cannot be negative');
  }
  await Future<void>.delayed(Duration(seconds: count));
  return '$count second has passed.';
}

class CounterController {
  final count = Beacon.writable(0);

  // the future will be recomputed whenever the counter changes
  late final _derivedFutureCounter =
      Beacon.future(() => counterFuture(count.value));

  // here we expose the future beacon as a readable beacon
  // so it's easier to mock/test. This is optional.
  ReadableBeacon<AsyncValue<String>> get derivedFutureCounter =>
      _derivedFutureCounter;
}
