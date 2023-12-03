import 'dart:html';

import 'package:collection/collection.dart';
import 'package:state_beacon/state_beacon.dart';

// Side note: To maintain readability, this example was not formatted using dart_fmt.

void main() {
  const konamiKeyCodes = <int>[
    KeyCode.UP,
    KeyCode.UP,
    KeyCode.DOWN,
    KeyCode.DOWN,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.B,
    KeyCode.A
  ];

  final result = querySelector('#result')!;

  final keyCodes =
      Beacon.stream(document.onKeyUp.map((event) => event.keyCode));

  final last10 = Beacon.bufferedCount<int>(3);

  keyCodes.subscribe((v) {
    // print('new value: $v');
    last10.add((v as AsyncData).value);
  });

  Beacon.filtered(
    <int>[],
    (p0, p1) {
      print('$p1, $p0');
      return IterableEquality<int>().equals(p1, konamiKeyCodes);
    },
  )
    ..wrap(last10)
    ..subscribe((_) {
      result.innerHtml = 'KONAMI!';
    });
}
