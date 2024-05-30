import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon_flutter/state_beacon_flutter.dart';

void main() {
  testWidgets('should dispose all beacons in State class', (tester) async {
    await tester.pumpWidget(const CoounterView());
    final state = tester.state<_CoounterViewState>(find.byType(CoounterView));

    expect(state.count.isDisposed, false);
    expect(state.doubledCount.isDisposed, false);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(state.count.isDisposed, true);
    expect(state.doubledCount.isDisposed, true);
  });
}

class CoounterView extends StatefulWidget {
  const CoounterView({super.key});

  @override
  State<CoounterView> createState() => _CoounterViewState();
}

class _CoounterViewState extends State<CoounterView>
    with BeaconControllerMixin {
  late final count = B.writable(0);
  late final doubledCount = B.derived(() => count.value * 2);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
