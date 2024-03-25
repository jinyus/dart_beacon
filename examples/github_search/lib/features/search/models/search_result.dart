import 'github_repo.dart';

class SearchResult {
  const SearchResult({required this.items});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map(
          (dynamic item) => GithubRepo.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return SearchResult(items: items);
  }

  final List<GithubRepo> items;
}
