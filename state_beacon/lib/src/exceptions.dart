part of 'base_beacon.dart';

class UninitializeLazyReadException implements Exception {
  final String message = 'LazyBeacon read before its value was set';

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
