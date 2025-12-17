part of 'search.dart';

class WeatherController extends BeaconController {
  final WeatherRepository repo;

  late final searchText = TextEditingBeacon(group: B);

  late final searchTextDebounced = searchText
      .filter((_, next) => next.text.trim().isNotEmpty)
      .debounce(k100ms * 10);

  late final _searchResults = B.future(
    () async {
      final query = searchTextDebounced.value.text;
      return await repo.fetchWeather(query);
    },
    manualStart: true,
  );

  // expose the search results as a readable beacon
  // to make it easier to test/mock. This is optional.
  ReadableBeacon<AsyncValue<Weather>> get searchResults => _searchResults;

  WeatherController(this.repo) {
    // start searching when the beacon is first set
    searchTextDebounced.subscribe((_) => start(), startNow: false);
  }

  void start() => _searchResults.start();

  void retry() => _searchResults.reset();
}
