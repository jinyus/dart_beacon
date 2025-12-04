class SharedPreferences {
  // This is just a mock of your real SharedPreferences
  // instance that you initialize when your app starts.
  static Future<SharedPreferences> getInstance() async {
    await Future.delayed(Duration(milliseconds: 100));
    return SharedPreferences();
  }
}
