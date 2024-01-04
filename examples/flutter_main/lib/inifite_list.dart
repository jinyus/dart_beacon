import 'package:example/const.dart';
import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';
import 'dart:math' as math;

class NoMoreItemsException implements Exception {}

sealed class ListItem {}

class ItemData extends ListItem {
  final String value;
  ItemData(this.value);
}

class ItemLoading extends ListItem {}

class ItemError extends ListItem {
  final Object? error;
  ItemError(this.error);
}

Future<List<String>> _fetchItems(int pageNum) async {
  await Future.delayed(const Duration(seconds: 1));

  if (pageNum > 5) throw NoMoreItemsException();

  // randomly throw an error
  if (pageNum > 2 && math.Random().nextBool()) {
    throw Exception('Network Error');
  }

  final start = (pageNum - 1) * 10;

  return List.generate(10, (index) => 'Item ${start + index}');
}

class Controller {
  final pageNum = Beacon.filtered(1);

  // this re-executes the future when the pageNum changes
  late final rawItems = Beacon.derivedFuture(
    () => _fetchItems(pageNum.value),
  );

  late final parsedItems = Beacon.writable(<ListItem>[ItemLoading()]);

  Controller() {
    // prevent the pageNum from changing when the list is loading
    pageNum.setFilter((_, __) => rawItems.value is! AsyncLoading);

    // transform raw items into ListItems
    parsedItems.wrap(
      rawItems,
      then: (beacon, newAsyncValue) {
        // get the current list
        final newList = beacon.peek().toList();

        // remove the last item if it's an ItemLoading or ItemError
        if (newList.last is! ItemData) {
          newList.removeLast();
        }

        beacon.value = switch (newAsyncValue) {
          // if the new value is AsyncData<List<String>>, add the items to the list
          AsyncData<List<String>>(value: final lst) => newList
            ..addAll(lst.map(ItemData.new))
            ..add(ItemLoading()),

          // if the new value is AsyncError, add the error to the list
          AsyncError(error: final err) => newList..add(ItemError(err)),

          // if the new value is AsyncLoading, add the loading indicator to the list
          _ => newList..add(ItemLoading()),
        };
      },
      startNow: false,
    );
  }
}

// you could use Provider or GetIt to provide the controller to the widget tree
final controller = Controller();

class InfiniteList extends StatelessWidget {
  const InfiniteList({super.key});

  @override
  Widget build(BuildContext context) {
    final count = controller.parsedItems.watch(context).length;
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
                      final item = controller.parsedItems.value[index];

                      return switch (item) {
                        ItemData(value: final value) => ItemTile(title: value),
                        ItemLoading() => const BottomWidget(),
                        ItemError(error: final err) => BottomWidget(error: err),
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
    this.error,
  });

  final Object? error;

  @override
  State<BottomWidget> createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // this widgets gets built when we reach the end of the list and we want to
      // load the next page when we reach to the end of the ListView.builder
      if (widget.error == null) {
        controller.pageNum.increment();
      }
    });
    super.initState();
  }

  final btnStyle = ElevatedButton.styleFrom(
    textStyle: k32Text,
    minimumSize: const Size(100, 60),
  );
  @override
  Widget build(BuildContext context) {
    if (widget.error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    const style = TextStyle(fontSize: 20);
    return widget.error is NoMoreItemsException
        ? const Text(
            'No More Items',
            style: style,
            textAlign: TextAlign.center,
          )
        : Column(
            children: [
              Text(
                widget.error?.toString() ?? 'Unknown Error',
                style: style,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                style: btnStyle,
                onPressed: controller.rawItems.reset,
                child: const Text('retry'),
              )
            ],
          );
  }
}
