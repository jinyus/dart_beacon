import 'package:github_search/core/constants.dart';
import 'package:github_search/features/search/models/search_result.dart';
import 'package:github_search/features/search/repo/github_search.dart';
import 'package:state_beacon/state_beacon.dart';

class GithubController extends BeaconController {
  GithubController(this._repo) {
    searchTermDebounced.next().then((_) => _results.start());
  }

  final GithubSearchRepository _repo;

  late final searchTerm = TextEditingBeacon();

  late final searchTermDebounced =
      searchTerm.filter((_, n) => n.text.isNotEmpty).debounce(k100ms * 5);

  late final _results = B.future(
    () => _repo.search(searchTermDebounced.value.text),
    manualStart: true,
  );

  ReadableBeacon<AsyncValue<SearchResult>> get results => _results;

  void retry() => _results.reset();
}
