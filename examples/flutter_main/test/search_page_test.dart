// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:example/search/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:state_beacon/state_beacon.dart';

class MockWeatherController extends Mock implements WeatherController {}

void main() {
  final weatherCtrl = MockWeatherController();

  testWidgets('Search Page Test', (WidgetTester tester) async {
    final searchTextBeacon = Beacon.lazyDebounced<String>();

    late final searchResults =
        Beacon.writable<AsyncValue<Weather>>(AsyncIdle());

    when(() => weatherCtrl.searchTextBeacon).thenReturn(searchTextBeacon);
    when(() => weatherCtrl.searchResults).thenReturn(searchResults);
    when(weatherCtrl.start).thenAnswer((_) {
      searchResults.value = AsyncLoading();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Provider<WeatherController>(
            create: (_) => weatherCtrl,
            child: const SearchPage(),
          ),
        ),
      ),
    );

    expect(find.text('Enter a city to search for its weather'), findsOneWidget);

    searchTextBeacon.value = 'new york';

    weatherCtrl.start();

    // wait for debounce

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final testWeather = Weather(
      cityName: 'New York',
      temperatureCelsius: 20,
    );
    searchResults.value = AsyncData(testWeather);

    await tester.pump();

    expect(find.text(testWeather.toString()), findsOneWidget);

    searchResults.value = AsyncError('error');

    await tester.pump();

    expect(find.text('Nextwork Error'), findsOneWidget);
  });
}
