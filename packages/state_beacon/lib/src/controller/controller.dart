// ignore_for_file: non_constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:state_beacon/state_beacon.dart';

/// A mixin that automatically disposes all beacons created by this Widget.
mixin BeaconControllerMixin<T extends StatefulWidget> on State<T> {
  /// Local BeaconCreator that automatically
  /// disposes all beacons created within this State class.
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
  @mustCallSuper
  void dispose() {
    B.disposeAll();
    super.dispose();
  }
}
