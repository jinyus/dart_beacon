import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:state_beacon_core/state_beacon_core.dart';
import 'package:state_beacon_flutter/src/value_notifier_beacon.dart';

part 'readable.dart';
part 'watch_observe.dart';
part 'writable.dart';

final Map<int, ValueNotifierBeacon<dynamic>> _vnCache = {};

@visibleForTesting

/// The number of value notifiers currently in use
/// This is used for testing purposes only
bool hasNotifier(BaseBeacon<dynamic> beacon) {
  return _vnCache.containsKey(beacon.hashCode);
}

ValueNotifier<T> _toValueNotifier<T>(ReadableBeacon<T> beacon) {
  final key = beacon.hashCode;

  final existing = _vnCache[key];

  if (existing != null) {
    return existing as ValueNotifierBeacon<T>;
  }

  final notifier = ValueNotifierBeacon(beacon.peek());

  _vnCache[key] = notifier;

  final unsub = beacon.subscribe(notifier.set, startNow: false);

  notifier.addDisposeCallback(() {
    unsub();
    _vnCache.remove(key);
  });

  beacon.onDispose(() {
    notifier.dispose();
    _vnCache.remove(key);
  });

  return notifier;
}
