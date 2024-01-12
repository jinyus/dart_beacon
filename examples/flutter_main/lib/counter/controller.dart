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

class Controller {
  final count = Beacon.writable(0);

  // the future will be recomputed whenever the counter changes
  late final derivedFutureCounter = Beacon.derivedFuture(() async {
    return await counterFuture(count.value);
  });
}
