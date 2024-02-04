import 'dart:async';

import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  Stream<int> sampleStream(int len) {
    return Stream.fromIterable(List.generate(len, (i) => i));
  }

  void addItems(StreamController<int> controller, int len) {
    for (var i = 0; i < len; i++) {
      controller.add(i);
    }
  }

  test('should set values emitted by stream', () async {
    final beacon = Beacon.derivedStream(() {
      return sampleStream(5);
    });

    final buff = beacon.bufferTime(duration: k1ms);

    expect(buff.value, isEmpty);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4]));
  });

  test('should unsub from old stream when dependency changes', () async {
    final controller = StreamController<int>.broadcast();

    final counter = Beacon.writable(5);

    // should increment when dependency changes
    var unsubs = 0;
    var listens = 0;

    controller.onCancel = () => unsubs++;

    controller.onListen = () {
      // print('listen');
      listens++;
      addItems(controller, counter.value);
    };

    final beacon = Beacon.derivedStream(() {
      counter.value;
      return controller.stream;
    });

    expect(listens, 1);

    final buff = beacon.bufferTime(duration: k1ms);

    expect(buff.value, isEmpty);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4]));

    counter.increment(); // dep changed, should unsub from old stream

    expect(unsubs, 1);
    expect(listens, 2);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4, 5]));

    counter.increment();

    expect(unsubs, 2); // dep changed, should unsub from old stream
    expect(listens, 3);

    await expectLater(buff.next(), completion([0, 1, 2, 3, 4, 5, 6]));

    beacon.dispose(); // should unsub when disposed

    expect(unsubs, 3);
    expect(listens, 3);
  });
}
