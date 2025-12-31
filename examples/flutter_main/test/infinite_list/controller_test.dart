import 'package:example/infinite_list/infinite_list.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements PostRepository {
  final Map<int, List<String>> pages;
  FakeRepo(this.pages);

  @override
  Future<List<String>> fetchItems(int page, {int limit = 10}) async {
    return pages[page] ?? <String>[];
  }
}

class FlakyRepo implements PostRepository {
  final Map<int, List<String>> pages;
  final Set<int> failOncePages;
  final Map<int, int> _calls = {};
  FlakyRepo(this.pages, {this.failOncePages = const {}});

  @override
  Future<List<String>> fetchItems(int page, {int limit = 10}) async {
    _calls[page] = (_calls[page] ?? 0) + 1;
    if (failOncePages.contains(page) && _calls[page] == 1) {
      throw Exception('fetch failed for page $page');
    }
    return pages[page] ?? <String>[];
  }
}

void main() {
  testWidgets('loads initial page and shows loading sentinel', (tester) async {
    final repo = FakeRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    final list = controller.items.peek();
    // Expect pageSize data items plus a loading sentinel
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(list.last, isA<ItemLoading>());
  });

  testWidgets('appends next page when loadNextPage is called', (tester) async {
    final repo = FakeRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
      2: List.generate(InfiniteController.pageSize, (i) => 'p2_item_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    // initial
    var list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(list.last, isA<ItemLoading>());

    // load next
    controller.loadNextPage();
    await tester.pumpAndSettle();

    // now should have 2 pages worth of data plus a loading sentinel
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize * 2);
    expect(list.last, isA<ItemLoading>());
  });

  testWidgets('shows no-more-items when less than pageSize returned',
      (tester) async {
    final repo = FakeRepo({
      1: List.generate(3, (i) => 'p1_item_$i'), // less than pageSize
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    final list = controller.items.peek();
    // data items then an ItemError(NoMoreItemsException)
    expect(list.whereType<ItemData>().length, 3);
    expect(list.last, isA<ItemEnd>());
  });

  testWidgets('retries after error and then loads data', (tester) async {
    final repo = FlakyRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
    }, failOncePages: {
      1
    });

    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    var list = controller.items.peek();
    // first attempt failed -> error sentinel present
    expect(list.last, isA<ItemError>());

    // retry
    controller.retryOnError();
    await tester.pumpAndSettle();

    list = controller.items.peek();
    // after retry should have data and loading sentinel (since repo returned full page)
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(list.last, isA<ItemLoading>());
  });

  testWidgets('refresh resets to page 1 and fetches new data', (tester) async {
    final repo = FakeRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_new_$i'),
      2: List.generate(InfiniteController.pageSize, (i) => 'p2_old_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    // move to page 2
    controller.loadNextPage();
    await tester.pumpAndSettle();

    var list = controller.items.peek();
    expect(list.whereType<ItemData>().any((d) => d.value.startsWith('p2_old_')),
        isTrue);

    // refresh should reset to page 1 and fetch p1_new
    await controller.refresh();
    await tester.pumpAndSettle();

    list = controller.items.peek();
    expect(list.whereType<ItemData>().any((d) => d.value.startsWith('p1_new_')),
        isTrue);
    expect(controller.pageNum.value, 1);
  });
}
