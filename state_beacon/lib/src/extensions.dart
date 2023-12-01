part of 'base_beacon.dart';

extension BoolUtils on WritableBeacon<bool> {
  void toggle() {
    value = !peek();
  }
}

extension ListUtils<T> on List<T> {
  /// Converts a list to [ListBeacon].
  ListBeacon<T> toSignal() {
    return ListBeacon<T>(this);
  }
}

extension StreamUtils<T> on Stream<T> {
  /// Converts a stream to [StreamBeacon].
  StreamBeacon<T> toSignal() {
    return StreamBeacon<T>(this);
  }
}

// extension MapUtils<K, V> on Map<K, V> {
//   /// Converts a map to [MapBeacon].
//   MapBeacon<K, V> toSignal() {
//     return MapBeacon<K, V>(this);
//   }
// }


