part of 'infinite_list.dart';

class InfiniteController extends BeaconController {
  static const pageSize = 10;

  final PostRepository repo;

  InfiniteController(this.repo) {
    // prevent the pageNum from changing when the list is loading
    pageNum.setFilter((_, __) => rawItems.isData);

    rawItems.subscribe(
      (newValue) {
        switch (newValue) {
          case AsyncData(value: final newItems):
            final didRefresh =
                pageNum.peek() == 1 && (pageNum.previousValue ?? 0) > 1;

            if (didRefresh) {
              items.clear();
            } else {
              items.removeLast(); // remove loading item
            }

            final hasMore = newItems.length == pageSize;

            items
              ..addAll(newItems.map(ItemData.new))
              ..add(hasMore ? ItemLoading() : ItemEnd());

          case AsyncError(:final error):
            items
              ..removeLast()
              ..add(ItemError(error));

          default:
            if (items.peek().last is! ItemLoading) {
              items
                ..removeLast()
                ..add(ItemLoading());
            }
        }
      },
      startNow: false,
    );
  }

  late final pageNum = B.filtered(1);

  // this re-executes the future when the pageNum changes
  late final rawItems = B.future(() async {
    final page = pageNum.value;
    return repo.fetchItems(page, limit: pageSize);
  });

  late final items = B.list<ListItem>([ItemLoading()]);

  void loadNextPage() => pageNum.increment();

  void retryOnError() => rawItems.reset();

  Future<dynamic> refresh() async {
    pageNum.reset(force: true);
    return rawItems.nextOrNull(filter: (n) => n.isData);
  }
}
