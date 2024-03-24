part of 'infinite_list.dart';

class InfiniteController extends BeaconController {
  static const pageSize = 10;

  final PostRepository repo;
  late final pageNum = B.filtered(1);

  // this re-executes the future when the pageNum changes
  late final rawItems = B.future(
    () => repo.fetchItems(pageNum.value, limit: pageSize),
  );

  late final parsedItems = B.writable(<ListItem>[ItemLoading()]);

  InfiniteController(this.repo) {
    // prevent the pageNum from changing when the list is loading
    pageNum.setFilter((_, __) => rawItems.isData);

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
          // if successful, add the items to the list
          AsyncData<List<String>>(value: final lst) => newList
            ..addAll(lst.map(ItemData.new))
            ..add(lst.length < pageSize
                ? ItemError(NoMoreItemsException())
                : ItemLoading()),

          // if an error occured, add the error to the list
          AsyncError(:final error) => newList..add(ItemError(error)),

          // add the loading indicator to the list
          _ => newList..add(ItemLoading()),
        };
      },
    );
  }
}
