import 'package:example/const.dart';
import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';
import 'dart:math' as math;

sealed class ListItem {}

class ItemData extends ListItem {
  final String value;
  ItemData(this.value);
}

class ItemLoading extends ListItem {}

class ItemError extends ListItem {
  final String error;
  ItemError(this.error);
}

Future<List<String>> _fetchItems(int pageNum) async {
  await Future.delayed(const Duration(seconds: 1));

  // randomly throw an error
  if (pageNum > 2 && math.Random().nextBool()) {
    throw Exception('Network Error');
  }

  final start = (pageNum - 1) * 10;

  return List.generate(10, (index) => 'Item ${start + index}');
}

final pageNum = Beacon.debounced(1, duration: k100ms);

// this re-executes the future when the pageNum changes
final rawItems = Beacon.derivedFuture(
  () => _fetchItems(pageNum.value),
  cancelRunning: false,
);

final parsedItems = Beacon.writable(<ListItem>[ItemLoading()]).wrap(
  rawItems,
  then: (beacon, newAsyncValue) {
    final newList = beacon.peek().toList();

    if (newList.last is! ItemData) {
      newList.removeLast();
    }

    beacon.value = switch (newAsyncValue) {
      AsyncData<List<String>>(value: final lst) => newList
        ..addAll(lst.map(ItemData.new))
        ..add(ItemLoading()),
      AsyncError(error: final err) => newList..add(ItemError(err.toString())),
      _ => newList..add(ItemLoading()),
    };
  },
  startNow: false,
);

class InfiniteList extends StatelessWidget {
  const InfiniteList({super.key});

  @override
  Widget build(BuildContext context) {
    final count = parsedItems.watch(context).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: math.min(500, MediaQuery.of(context).size.width * 0.8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('Infinite List', style: k24Text),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final item = parsedItems.value[index];

                      return switch (item) {
                        ItemData(value: final value) => ItemTile(title: value),
                        ItemLoading() => const BottomWidget(),
                        ItemError(error: final err) =>
                          BottomWidget(errorMsg: err),
                      };
                    },
                    itemCount: count,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: k24Text),
      tileColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}

class BottomWidget extends StatefulWidget {
  const BottomWidget({
    super.key,
    this.errorMsg,
  });

  final String? errorMsg;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  var isLoading = false;

  @override
  void initState() {
    // load the next page when we reach to the end of the ListView.builder
    if (widget.errorMsg == null) {
      pageNum.value++;
    }
    super.initState();
  }

  final btnStyle = ElevatedButton.styleFrom(
    textStyle: k32Text,
    minimumSize: const Size(100, 60),
  );
  @override
  Widget build(BuildContext context) {
    if (widget.errorMsg != null) {
      return Column(
        children: [
          ItemTile(title: widget.errorMsg!),
          const SizedBox(height: 5),
          ElevatedButton(
            style: btnStyle,
            onPressed: rawItems.reset,
            child: const Text('retry'),
          )
        ],
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
