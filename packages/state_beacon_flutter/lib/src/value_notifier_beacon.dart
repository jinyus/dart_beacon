// ignore_for_file: public_member_api_docs, use_setters_to_change_properties

import 'package:flutter/foundation.dart';

/// @macro [ValueNotifierBeacon]
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
    for (final cb in disposeListeners) {
      cb();
    }
    super.dispose();
  }
}
