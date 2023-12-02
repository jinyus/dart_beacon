import 'package:example/const.dart';
import 'package:example/data/weather_model.dart';
import 'package:example/data/weather_repo.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_state_beacon/flutter_state_beacon.dart';

final searchTextBeacon = Beacon.debounced('', duration: k100ms * 10);

final searchResults = Beacon.derivedFuture(() async {
  final query = searchTextBeacon.value;
  return await FakeWeatherRepository().fetchWeather(query);
});

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: math.min(500, MediaQuery.of(context).size.width * 0.8),
          child: const Column(
            children: [
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

class SearchInput extends StatefulWidget {
  const SearchInput({super.key});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final controller = TextEditingController(text: searchTextBeacon.peek());

  @override
  void initState() {
    controller.addListener(() {
      searchTextBeacon.value = controller.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: k24Text,
      controller: controller,
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
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          k16SizeBox,
          switch (searchResults.watch(context)) {
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
