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

class KonamiController extends BeaconController {
  // this is throttled because FocusNode.onKey can be
  // triggered multiple times for a single key press
  late final keys = B.lazyThrottled<String>(duration: k100ms * 2);

  late final last10 = keys.buffer(10);
}
