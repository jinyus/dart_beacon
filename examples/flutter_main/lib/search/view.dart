part of 'search.dart';

final weatherControllerRef = Ref.scoped(
  (ctx) => WeatherController(WeatherRepository()),
);

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: math.min(500, MediaQuery.of(context).size.width * 0.8),
          child: ListView(
            children: const [
              Text('Weather Search', style: TextStyle(fontSize: 48)),
              k16SizeBox,
              SearchInput(),
              SearchResults(),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    final wController = weatherControllerRef.of(context);
    return TextField(
      style: k24Text,
      controller: wController.searchText.controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Enter a city',
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchResults = weatherControllerRef.select(
      context,
      (c) => c.searchResults,
    );
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          k16SizeBox,
          switch (searchResults) {
            AsyncData<Weather> data => Text(
                '${data.value}',
                style: k32Text,
                textAlign: TextAlign.center,
              ),
            AsyncError _ => Column(
                children: [
                  const Text(
                    'Nextwork Error',
                    style: TextStyle(color: Colors.red, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () => weatherControllerRef.read(context).retry(),
                    child: const Text('retry'),
                  )
                ],
              ),
            AsyncLoading() => const CircularProgressIndicator(),
            AsyncIdle() => const Text(
                'Enter a city to search for its weather',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
          },
          const Text(
            "NB: The text input is debounced by 1s so it will"
            " only start searching 1s after you stop typing.",
            textAlign: TextAlign.center,
            style: k24Text,
          ),
        ],
      ),
    );
  }
}
