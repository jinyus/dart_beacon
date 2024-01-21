part of 'infinite_list.dart';

class Controller {
  static const pageSize = 10;

  final PostRepository repo;
  final pageNum = Beacon.filtered(1);

  // this re-executes the future when the pageNum changes
  late final rawItems = Beacon.derivedFuture(
    () => repo.fetchItems(pageNum.value, limit: pageSize),
  );

  late final parsedItems = Beacon.writable(<ListItem>[ItemLoading()]);

  Controller(this.repo) {
    // prevent the pageNum from changing when the list is loading
    pageNum.setFilter((_, __) => rawItems.value is! AsyncLoading);

    // transform raw items into ListItems
    parsedItems.wrap(
      rawItems,
      startNow: false,
      then: (newAsyncValue) {
        // get the current list
        final newList = parsedItems.peek().toList();

        // remove the last item if it's an ItemLoading or ItemError
        if (newList.last is! ItemData) {
          newList.removeLast();
        }

        parsedItems.value = switch (newAsyncValue) {
          // if the new value is AsyncData<List<String>>, add the items to the list
          AsyncData<List<String>>(value: final lst) => newList
            ..addAll(lst.map(ItemData.new))
            ..add(lst.length < pageSize
                ? ItemError(NoMoreItemsException())
                : ItemLoading()),

          // if the new value is AsyncError, add the error to the list
          AsyncError(:final error) => newList..add(ItemError(error)),

          // if the new value is AsyncLoading, add the loading indicator to the list
          _ => newList..add(ItemLoading()),
        };
      },
    );
  }
}
