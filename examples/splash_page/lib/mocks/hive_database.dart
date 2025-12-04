var _shouldFail = true;

class HiveDatabase {
  // This is just a mock of your real database
  // that you initialize when your app starts.
  Future<void> init() async {
    await Future.delayed(Duration(seconds: 1));
    if (_shouldFail) {
      _shouldFail = false;
      throw Exception('Failed to initialize HiveDatabase');
    }
  }
}
