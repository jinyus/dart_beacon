import 'package:github_search/core/constants.dart';
import 'package:github_search/features/search/repo/github_search.dart';
import 'package:state_beacon/state_beacon.dart';

class GithubController with BeaconController {
  GithubController(this._repo) {
    _startSearchingOnValidQuery();
  }

  final GithubSearchRepository _repo;

  late final _searchTerm = B.debounced('', duration: k100ms * 5);

  late final results = B.future(
    () => _repo.search(_searchTerm.value),
    manualStart: true,
  );

  void onTextChanged(String text) {
    if (text.isEmpty) {
      results.idle();
      _startSearchingOnValidQuery();
    }

    _searchTerm.set(text);
  }

  // this listens to the search term beacon and starts the future beacon
  // if the search term is valid
  void _startSearchingOnValidQuery() {
    _searchTerm
        .next(filter: (s) => s.trim().isNotEmpty)
        .then((_) => results.start());
  }
}
