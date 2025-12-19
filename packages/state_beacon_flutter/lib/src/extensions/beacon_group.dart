part of 'extensions.dart';

/// Flutter extensions on BeaconGroup
extension FlutterBeaconGroupx on BeaconGroup {
  /// A beacon that wraps a `TextEditingController`. All changes to the
  /// controller are reflected in the beacon and vice versa.
  /// ```dart
  /// final beacon = TextEditingBeacon();
  /// final controller = beacon.controller;
  ///
  /// controller.text = 'Hello World';
  ///
  /// expect(beacon.value.text.'Hello World');
  ///
  /// ```
  TextEditingBeacon textEditing({String? text, String? name}) {
    return TextEditingBeacon(text: text, name: name, group: this);
  }
}
