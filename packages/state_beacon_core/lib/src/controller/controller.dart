import 'package:state_beacon_core/state_beacon_core.dart';

/// An abstract mixin class that automatically disposes all beacons created by
/// this controller.
abstract mixin class BeaconController implements Disposable {
  /// Local BeaconCreator that automatically
  /// disposes all beacons created by this controller.
  ///
  /// ### All beacons must be created with as a `late` variable.
  /// ```dart
  /// late final age = B.writable(50);
  ///  ^
  ///  |
  /// this is required
  /// ```
  final B = BeaconGroup();

  /// Disposes all beacons created by this controller.
  @override
  void dispose() {
    B.disposeAll();
  }
}
