part of 'search_page.dart';

class _SearchForm extends StatelessWidget {
  const _SearchForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchBar(),
        _SearchBody(),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = searchControllerRef.read(context);
    _textController.addListener(() {
      controller.onTextChanged(_textController.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = searchControllerRef.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _textController,
        autocorrect: false,
        onChanged: controller.onTextChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: _textController.clear,
            child: const Icon(Icons.clear),
          ),
          border: const OutlineInputBorder(),
          hintText: 'Enter a search term',
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final results = searchControllerRef.select(context, (c) => c.results);
    final textStyle = Theme.of(context).textTheme.headlineMedium;
    return switch (results) {
      AsyncIdle() => Text('Type a query to begin', style: textStyle),
      AsyncLoading() => const CircularProgressIndicator(),
      AsyncError(:final error) => Text('$error', style: textStyle),
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
