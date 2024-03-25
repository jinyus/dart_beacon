import 'package:flutter/material.dart';
import 'package:github_search/features/search/models/github_repo.dart';
import 'package:github_search/features/search/models/search_result.dart';
import 'package:github_search/features/search/repo/github_search.dart';
import 'package:github_search/features/search/ui/controller/github_controller.dart';
import 'package:state_beacon/state_beacon.dart';
import 'package:url_launcher/url_launcher.dart';

part 'search_form.dart';

final searchRepoRef = Ref.scoped((_) => GithubSearchRepository());
final searchControllerRef = Ref.scoped(
  (ctx) => GithubController(searchRepoRef.read(ctx)),
);

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Github Search')),
      body: const _SearchForm(),
    );
  }
}
