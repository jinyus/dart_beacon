import 'package:flutter/widgets.dart';
import 'package:state_beacon/state_beacon.dart';

/// Extensions for [ScopedRef] that provide a more convenient way to watch
/// the beacons in a [BeaconController] instance.
extension LiteRefBeaconControllerExt<C extends BeaconController>
    on ScopedRef<C> {
  /// Watches the beacon returned by [selector]
  /// instance.
  ///
  /// ```dart
  /// class SettingsPage extends StatelessWidget {
  ///   const SettingsPage({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final theme = settingsControllerRef.select(context, (c) => c.theme);
  ///     return Text(theme);
  ///   }
  /// }
  /// ```
  /// This is equivalent to:
  /// ```dart
  /// class SettingsPage extends StatelessWidget {
  ///   const SettingsPage({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final controller = settingsControllerRef.of(context);
  ///     final theme = controller.theme.watch(context);
  ///     return Text(theme);
  ///   }
  /// }
  ///
  /// ```
  T select<T>(BuildContext context, BeaconSelector<T, C> selector) {
    final controller = of(context);
    return controller.select(context, selector);
  }

  /// Like [select] but watches two beacons and returns a record
  /// with their values.
  ///
  /// ```dart
  /// class SettingsPage extends StatelessWidget {
  ///   const SettingsPage({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final (theme, darkTheme) = settingsControllerRef.select2(
  ///       context,
  ///       (c) => (c.theme, c.darkTheme),
  ///     );
  ///     return Text(theme);
  ///   }
  /// }
  /// ```
  (T1, T2) select2<T1, T2>(
    BuildContext context,
    BeaconSelector2<T1, T2, C> selector,
  ) {
    final controller = of(context);
    return controller.select2(context, selector);
  }

  /// Like [select2] but watches three beacons and returns a record
  /// with their values.
  (T1, T2, T3) select3<T1, T2, T3>(
    BuildContext context,
    BeaconSelector3<T1, T2, T3, C> selector,
  ) {
    final controller = of(context);
    return controller.select3(context, selector);
  }
}

/// Extensions for [ScopedRef] that provide a more convenient way to watch
/// a [ReadableBeacon].
extension LiteRefBeaconExt<T> on ScopedRef<ReadableBeacon<T>> {
  /// Watch the beacon inside the ScopedRef and return its value.
  T watch(BuildContext context) {
    final beacon = of(context);
    return beacon.watch(context);
  }
}
