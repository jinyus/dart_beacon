part of 'search_page.dart';

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final results = searchControllerRef.select(context, (c) => c.results);
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return switch (results) {
      AsyncIdle() => Text('Type a query to begin', style: textStyle),
      AsyncLoading() => const CircularProgressIndicator(),
      AsyncError(:final error) => _SearchError(error: error.toAppError()),
      AsyncData<SearchResult>(:final value) => value.items.isEmpty
          ? Text('No Results', style: textStyle)
          : Expanded(child: _SearchResults(items: value.items)),
    };
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.items});

  final List<GithubRepo> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.item});

  final GithubRepo item;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          child: Image.network(item.owner.avatarUrl),
        ),
        title: Text(item.fullName, style: textStyle),
        onTap: () => launchUrl(Uri.parse(item.htmlUrl)),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.error});

  final AppError error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            error.message,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => searchControllerRef.read(context).retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
