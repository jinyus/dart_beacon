part of 'search.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<WeatherController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: math.min(500, MediaQuery.of(context).size.width * 0.8),
          child: ListView(
            children: [
              const Text('Weather Search', style: TextStyle(fontSize: 48)),
              k16SizeBox,
              SearchInput(controller),
              SearchResults(controller),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchInput extends StatefulWidget {
  const SearchInput(this.controller, {super.key});

  final WeatherController controller;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final textController = TextEditingController();

  @override
  void initState() {
    final searchTextBeacon = widget.controller.searchTextBeacon;
    textController.addListener(() {
      if (textController.text.isEmpty) return;
      searchTextBeacon.value = textController.text;
    });

    // Start searching when beacon is first set
    searchTextBeacon.next().then((value) => widget.controller.start());

    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: k24Text,
      controller: textController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Enter a city',
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults(this.controller, {super.key});

  final WeatherController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          k16SizeBox,
          switch (controller.searchResults.watch(context)) {
            AsyncData<Weather>(value: final v) => Text(
                '$v',
                style: k32Text,
                textAlign: TextAlign.center,
              ),
            AsyncError(error: final _) => const Text(
                'Nextwork Error',
                style: TextStyle(color: Colors.red, fontSize: 24),
                textAlign: TextAlign.center,
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
