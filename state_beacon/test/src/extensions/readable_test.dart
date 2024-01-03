import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  test('should convert a beacon to a stream', () async {
    var beacon = Beacon.writable(0);
    var onCanceledCalled = false;
    var stream = beacon.toStream(
      onCancel: () {
        onCanceledCalled = true;
      },
    );

    expect(stream, isA<Stream<int>>());

    expect(
        stream,
        emitsInOrder([
          0,
          1,
          2,
          emitsDone,
        ]));

    beacon.value = 1;
    beacon.value = 2;
    beacon.dispose();

    expect(onCanceledCalled, true);
  });
}
