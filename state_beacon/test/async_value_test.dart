import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  Future<void> testFuture(bool crash) async {
    if (crash) {
      throw Exception('error');
    }
  }

  test('should return AsyncData when future is successful', () async {
    final result = await AsyncValue.tryCatch(() => testFuture(false));
    expect(result, isA<AsyncData>());
  });

  test('should return AsyncError when future throws', () async {
    final result = await AsyncValue.tryCatch(() => testFuture(true));
    expect(result, isA<AsyncError>());
  });
}
