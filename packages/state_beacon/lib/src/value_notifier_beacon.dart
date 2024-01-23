import 'package:flutter/foundation.dart';

class ValueNotifierBeacon<T> extends ValueNotifier<T> {
  ValueNotifierBeacon(super.value);

  final disposeListeners = <VoidCallback>[];

  void addDisposeCallback(VoidCallback callback) {
    disposeListeners.add(callback);
  }

  void set(T newValue) {
    value = newValue;
  }

  @override
  void dispose() {
    for (var cb in disposeListeners) {
      cb();
    }
    super.dispose();
  }
}
