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

class KonamiController {
  // this is throttled because FocusNode.onKey can be
  // triggered multiple times for a single key press
  // we expose it as a WritableBeacon so that we can
  // mock it in tests without dealing with throttling
  final WritableBeacon<String> keys =
      Beacon.lazyThrottled<String>(duration: k100ms * 2);

  late final last10 = keys.buffer(10);
}
