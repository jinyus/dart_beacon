part of 'konami.dart';

const konamiCodes = [
  "Arrow Up",
  "Arrow Up",
  "Arrow Down",
  "Arrow Down",
  "Arrow Left",
  "Arrow Right",
  "Arrow Left",
  "Arrow Right",
  "B",
  "A",
];

class Controller {
  final keys = Beacon.lazyThrottled<String>(duration: k100ms * 2);
  late final last10 = Beacon.bufferedCount<String>(10).wrap(
    keys,
    startNow: false,
  );
}
