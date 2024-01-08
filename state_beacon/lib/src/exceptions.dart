part of 'base_beacon.dart';

class UninitializeLazyReadException implements Exception {
  late final String message;

  UninitializeLazyReadException(String label)
      : message = '$label was read before being initialized. '
            'You must either provide an initial value or set the value before reading it.';

  @override
  String toString() => 'UninitializeLazyReadException: $message';
}

class CircularDependencyException implements Exception {
  late final String message;

  CircularDependencyException(String label)
      : message = 'Circular dependency detected in $label. '
            'Effects/DerivedBeacons cannot mutate values they depend on. '
            'You might want to wrap the mutation in a `Beacon.untracked()`';

  @override
  String toString() => 'CircularDependencyException: $message';
}

class WrapTargetWrongTypeException implements Exception {
  late final String message;
  WrapTargetWrongTypeException(String consumerLabel, String targetLabel)
      : message =
            '$consumerLabel cannot wrap $targetLabel as they are not of the same type. '
                'If you want to wrap a beacon of a different type, you must provide a `then` function';

  @override
  String toString() => 'WrapTargetWrongTypeException: $message';
}
