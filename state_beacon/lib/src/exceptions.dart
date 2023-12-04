part of 'base_beacon.dart';

class UninitializeLazyReadException implements Exception {
  final String message = 'Lazy beacon read before its value was set';

  UninitializeLazyReadException();

  @override
  String toString() => 'UninitializeLazyReadException: $message';
}

class CircularDependencyException implements Exception {
  final String message =
      'Cycle Detected: Effects/DerivedBeacons cannot mutate values they depend on';

  CircularDependencyException();

  @override
  String toString() => 'CircularDependencyException: $message';
}

class FutureStartedTwiceException implements Exception {
  final String message = 'FutureBeacon.start() must only be called once';

  FutureStartedTwiceException();

  @override
  String toString() => 'FutureStartedTwiceException: $message';
}

class DerivedBeaconStartedTwiceException implements Exception {
  final String message = 'DerivedBeacon.start() must only be called once';

  DerivedBeaconStartedTwiceException();

  @override
  String toString() => 'DerivedBeaconStartedTwiceException: $message';
}

class WrapTargetWrongTypeException implements Exception {
  final String message =
      'The type of the target beacon must be the same as the type of the wrapper beacon if no `then` function is provided';

  WrapTargetWrongTypeException();

  @override
  String toString() => 'WrapTargetWrongTypeException: $message';
}
