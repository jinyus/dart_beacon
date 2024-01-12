part of 'search.dart';

class Controller {
  final WeatherRepository repo;

  final searchTextBeacon = Beacon.lazyDebounced(duration: k100ms * 10);

  late final searchResults = Beacon.derivedFuture(
    () async {
      final query = searchTextBeacon.value;
      return await repo.fetchWeather(query);
    },
    manualStart: true,
  );

  Controller(this.repo);

  void start() => searchResults.start();
}
