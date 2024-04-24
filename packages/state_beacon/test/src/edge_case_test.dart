import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_beacon/state_beacon.dart';

typedef Themes = ({ThemeData lightTheme});

class Customization {
  const Customization({
    this.themes = const {},
  });

  final Map<String, Themes> themes;
}

class PrefController {
  PrefController({
    required this.defaultThemeName,
    required this.appCustomization,
  });

  final String? defaultThemeName;
  final Customization appCustomization;

  late final selectedTheme = Beacon.writable<String>(
    defaultThemeName ?? 'Default',
    name: 'selectedTheme',
  );

  late final lightTheme = Beacon.derived(
    () {
      final selectedThemeName = selectedTheme.value;
      return appCustomization.themes[selectedThemeName]?.lightTheme;
    },
    name: 'lightTheme',
  );
}

const color1 = Color(0xFF000000);
const color2 = Color(0xFFFF0000);
const colorFallback = Color(0xFFFFFFFF);

const myWidgetKey = Key('myWidgetKey');

void main() {
  testWidgets('Should change theme with empty', (widgetTester) async {
    // BeaconObserver.instance = LoggingObserver();
    final controller = PrefController(
      defaultThemeName: null,
      appCustomization: Customization(
        themes: {
          '1': (lightTheme: ThemeData.light().copyWith(primaryColor: color1)),
          '2': (lightTheme: ThemeData.light().copyWith(primaryColor: color2)),
        },
      ),
    );

    await widgetTester.pumpWidget(MyApp(controller: controller));
    expect(controller.selectedTheme.peek(), 'Default');
    var byKey = find.byKey(myWidgetKey);
    expect(byKey.first, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, colorFallback);

    controller.selectedTheme.value = '2';
    await widgetTester.pumpAndSettle();
    expect(controller.selectedTheme.peek(), '2');
    byKey = find.byKey(myWidgetKey);
    expect(byKey, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color2);

    controller.selectedTheme.value = '1';
    await widgetTester.pumpAndSettle();
    expect(controller.selectedTheme.peek(), '1');
    byKey = find.byKey(myWidgetKey);
    expect(byKey, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color1);
  });

  testWidgets('Should change theme with invalid predefined value',
      (widgetTester) async {
    // BeaconObserver.instance = LoggingObserver();
    final controller = PrefController(
      defaultThemeName: 'value not exists',
      appCustomization: Customization(
        themes: {
          '1': (lightTheme: ThemeData.light().copyWith(primaryColor: color1)),
          '2': (lightTheme: ThemeData.light().copyWith(primaryColor: color2)),
        },
      ),
    );

    await widgetTester.pumpWidget(MyApp(controller: controller));
    expect(controller.selectedTheme.peek(), 'value not exists');
    var byKey = find.byKey(myWidgetKey);
    expect(byKey.first, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, colorFallback);

    controller.selectedTheme.value = '2';
    await widgetTester.pumpAndSettle();
    expect(controller.selectedTheme.peek(), '2');
    byKey = find.byKey(myWidgetKey);
    expect(byKey, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color2);

    controller.selectedTheme.value = '1';
    await widgetTester.pumpAndSettle();
    expect(controller.selectedTheme.peek(), '1');
    byKey = find.byKey(myWidgetKey);
    expect(byKey, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color1);
  });

  testWidgets('Should change theme with predefined value',
      (widgetTester) async {
    final controller = PrefController(
      defaultThemeName: '1',
      appCustomization: Customization(
        themes: {
          '1': (lightTheme: ThemeData.light().copyWith(primaryColor: color1)),
          '2': (lightTheme: ThemeData.light().copyWith(primaryColor: color2)),
        },
      ),
    );

    // BeaconObserver.useLogging();

    await widgetTester.pumpWidget(MyApp(controller: controller));
    expect(controller.selectedTheme.peek(), '1');
    var byKey = find.byKey(myWidgetKey);
    expect(byKey.first, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color1);

    controller.selectedTheme.value = '2';
    await widgetTester.pumpAndSettle();
    expect(controller.selectedTheme.peek(), '2');
    byKey = find.byKey(myWidgetKey);
    expect(byKey, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color2);

    controller.selectedTheme.value = '1';
    await widgetTester.pumpAndSettle();
    expect(controller.selectedTheme.peek(), '1');
    byKey = find.byKey(myWidgetKey);
    expect(byKey, findsOneWidget);
    expect(widgetTester.widget<ColoredBox>(byKey).color, color1);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.controller,
    super.key,
  });

  final PrefController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: controller.lightTheme.watch(context) ??
          ThemeData.light().copyWith(primaryColor: colorFallback),
      home: Builder(
        builder: (ctx) {
          return Scaffold(
            body: ColoredBox(
              key: myWidgetKey,
              color: Theme.of(ctx).primaryColor,
            ),
          );
        },
      ),
    );
  }
}
