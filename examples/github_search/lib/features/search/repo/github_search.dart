import 'dart:convert';

import 'package:github_search/features/search/models/search_result_error.dart';
import 'package:http/http.dart' as http;

import '../models/search_result.dart';

class GithubSearchRepository {
  GithubSearchRepository({
    http.Client? httpClient,
    this.baseUrl = 'https://api.github.com/search/repositories?q=',
  }) : httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;

  Future<SearchResult> search(String term) async {
    final response = await httpClient.get(Uri.parse('$baseUrl$term'));
    final results = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}
