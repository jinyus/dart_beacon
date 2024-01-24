// ignore_for_file: public_member_api_docs

part of 'base_beacon.dart';

class UninitializeLazyReadException implements Exception {
  UninitializeLazyReadException(String label)
      : message = '''
$label was read before being initialized.  You must either provide an initial value or set the value before reading it.''';

  late final String message;

  @override
  String toString() => 'UninitializeLazyReadException: $message';
}

class CircularDependencyException implements Exception {
  CircularDependencyException(String watcher, String label)
      : message = '''
Circular dependency detected:
$watcher tried to mutate $label.
Effects/DerivedBeacons cannot mutate values they depend on. 
You might want to wrap the mutation in a `Beacon.untracked()`''';

  late final String message;

  @override
  String toString() => 'CircularDependencyException: $message';
}

class WrapTargetWrongTypeException implements Exception {
  WrapTargetWrongTypeException(String consumerLabel, String targetLabel)
      : message = '''
$consumerLabel cannot wrap $targetLabel as they are not of the same type. If you want to wrap a beacon of a different type, you must provide a `then` function''';
  late final String message;

  @override
  String toString() => 'WrapTargetWrongTypeException: $message';
}
