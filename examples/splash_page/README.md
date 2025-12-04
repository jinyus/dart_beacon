# Splash Page Example

This example demonstrates how to implement a splash page in aFlutter using State Beacon for state management and dependency injection.

## Key Components

### 1. Startup Beacon

The core of the splash page implementation is the `_startUpBeacon` in [`lib/app.dart`](examples/splash_page/lib/app.dart:7):

```dart
final _startUpBeacon = Ref.scoped((_) => Beacon.future(startUp));
```

### 2. Dependency Initialization

The [`startUp()`](examples/splash_page/lib/setup_dependencies.dart:34) function initializes all asynchronous dependencies:

```dart
Future<void> startUp() async {
  await MediaKit.ensureInitialized();
  final sharedPref = await SharedPreferences.getInstance();
  await hiveDbRef.instance.init();

  // assign all the late singleton refs at the end
  // this should be done after all async initializations are complete
  sharedPrefRef = Ref.singleton<SharedPreferences>(() => sharedPref);
}
```

## Parallel Initialization

For better performance, you can use the parallel initialization approach:

```dart
Future<void> startUpParallel() async {
  final mediaKitFuture = MediaKit.ensureInitialized();
  final sharedPrefFuture = SharedPreferences.getInstance();
  final hiveDbInitFuture = hiveDbRef.instance.init();

  final (_, sharedPref, _) = await (
    mediaKitFuture,
    sharedPrefFuture,
    hiveDbInitFuture,
  ).wait;

  sharedPrefRef = Ref.singleton<SharedPreferences>(() => sharedPref);
}
```

### 3. App Routing Logic

The main [`App`](examples/splash_page/lib/app.dart:9) widget uses a switch statement to route between splash screen and home page:

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    theme: themeData,
    home: switch (_startUpBeacon.watch(context)) {
      AsyncData() => const Home(),          // Success: Show home page
      AsyncError e => SplashScreen(errorText: e.error.toString()),  // Error: Show error
      _ => const SplashScreen(),           // Loading: Show splash
    },
  );
}
```

## How It Works

1. **Initialization**: When the app starts, `_startUpBeacon` begins executing the `startUp()` function
2. **Loading State**: While dependencies initialize, the splash screen shows a loading indicator
3. **Success State**: When all dependencies are ready, the app transitions to the home page
4. **Error State**: If initialization fails, the splash screen shows the error and provides a retry button

## Running the Example

```bash
cd examples/splash_page
flutter run
```

This example demonstrates a clean, maintainable approach to handling app initialization with proper state management and error handling.
