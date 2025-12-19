part of 'extensions.dart';

/// A function that takes a [BeaconController] and returns 1 of its beacon.
typedef BeaconSelector<T, C> = ReadableBeacon<T> Function(C);

/// A function that takes a [BeaconController] and
/// returns a record of 2 of its beacons.
typedef BeaconSelector2<T1, T2, C> = (
  ReadableBeacon<T1>,
  ReadableBeacon<T2>,
)
    Function(C);

/// A function that takes a [BeaconController] and
/// returns a record of 3 of its beacons.
typedef BeaconSelector3<T1, T2, T3, C>
    = (ReadableBeacon<T1>, ReadableBeacon<T2>, ReadableBeacon<T3>) Function(C);

/// Extensions that provide a more convenient way to watch
/// the beacons in a [BeaconController] instance.
extension BeaconControllerSelectExt<C extends BeaconController> on C {
  /// Watches the beacon returned by [selector]
  /// instance.
  ///
  /// ```dart
  /// final settingsController = SettingsController();
  /// class SettingsPage extends StatelessWidget {
  ///   const SettingsPage({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final theme = settingsController.select(context, (c) => c.theme);
  ///     return Text(theme);
  ///   }
  /// }
  /// ```
  T select<T>(BuildContext context, BeaconSelector<T, C> selector) {
    return selector(this).watch(context);
  }

  /// Like [select] but watches two beacons and returns a record
  /// with their values.
  ///
  /// ```dart
  /// final settingsController = SettingsController();
  /// class SettingsPage extends StatelessWidget {
  ///   const SettingsPage({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final (theme, darkTheme) = settingsController.select2(
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
    final (beacon1, beacon2) = selector(this);
    return (beacon1.watch(context), beacon2.watch(context));
  }

  /// Like [select2] but watches three beacons and returns a record
  /// with their values.
  (T1, T2, T3) select3<T1, T2, T3>(
    BuildContext context,
    BeaconSelector3<T1, T2, T3, C> selector,
  ) {
    final (beacon1, beacon2, beacon3) = selector(this);
    return (
      beacon1.watch(context),
      beacon2.watch(context),
      beacon3.watch(context)
    );
  }
}
