part of 'search.dart';

class WeatherController {
  final WeatherRepository repo;

  final WritableBeacon<String> searchTextBeacon =
      Beacon.lazyDebounced(duration: k100ms * 10);

  late final _searchResults = Beacon.derivedFuture(
    () async {
      final query = searchTextBeacon.value;
      return await repo.fetchWeather(query);
    },
    manualStart: true,
  );

  // expose the search results as a readable beacon
  // to make it easier to test/mock.
  ReadableBeacon<AsyncValue<Weather>> get searchResults => _searchResults;

  WeatherController(this.repo);

  void start() => _searchResults.start();
}
