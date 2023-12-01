import 'package:flutter/widgets.dart';
import 'package:flutter_state_beacon/flutter_state_beacon.dart';

typedef ElementUnsub = ({
  WeakReference<Element> elementRef,
  void Function() unsub
});

final Map<(int, int), ElementUnsub> _subscribers = {};

const k10seconds = Duration(seconds: 10);

var _lastPurge = DateTime.now().subtract(k10seconds);

final s = Beacon.writable(0);

extension BeaconUtils<T> on BaseBeacon<T> {
  /// Watches a beacon for changes and triggers a widget
  /// rebuild when its value changes.
  ///
  /// Note: must be called within a widget's build method.
  ///
  /// Usage:
  /// ```dart
  /// final counter = Beacon.writable(0);
  ///
  /// class Counter extends StatelessWidget {
  ///  const Counter({super.key});

  ///  @override
  ///  Widget build(BuildContext context) {
  ///    final count = counter.watch(context);
  ///    return Text(count.toString());
  ///  }
  ///}
  /// ```
  T watch(BuildContext context) {
    final key = (hashCode, context.hashCode);

    void rebuildWidget(T value) {
      final record = _subscribers[key]!;

      final target = record.elementRef.target;
      final isMounted = target?.mounted ?? false;

      if (isMounted) {
        target!.markNeedsBuild();
      } else {
        final removedRecord = _subscribers.remove(key);
        removedRecord?.unsub();
      }
    }

    if (!_subscribers.containsKey(key)) {
      final unsub = subscribe(rebuildWidget);

      _subscribers[key] = (
        elementRef: WeakReference(context as Element),
        unsub: unsub,
      );
    }

    _cleanUp();

    return peek();
  }
}

void _cleanUp() {
  final now = DateTime.now();

  // only clean up if there are more than 10 subscribers
  // and it's been more than 10 seconds
  if (_subscribers.length < 10 || now.difference(_lastPurge) < k10seconds) {
    return;
  }
  _lastPurge = now;

  _subscribers.removeWhere((key, value) {
    final shouldRemove = value.elementRef.target == null;
    if (shouldRemove) {
      value.unsub();
    }
    return shouldRemove;
  });
}
