part of '../base_beacon.dart';

class LazyBeacon<T> extends ReadableBeacon<T> {
  bool _isEmpty = true;

  LazyBeacon([T? initialValue]) {
    if (initialValue != null) {
      _initialValue = initialValue;
      _value = initialValue;
      _isEmpty = false;
    }
  }

  set value(T newValue) {
    if (_isEmpty) {
      _isEmpty = false;
      _initialValue = newValue;
      _previousValue = newValue;
      _value = newValue;
    } else {
      _setValue(newValue);
    }
  }

  @override
  T get value {
    if (_isEmpty) {
      throw UninitializeLazyReadException();
    }
    final observer = _Effect.current();
    if (observer != null) {
      _subscribe(observer, listeners);
    }
    return _value;
  }
}
