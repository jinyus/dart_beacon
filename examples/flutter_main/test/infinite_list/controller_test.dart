import 'package:example/infinite_list/infinite_list.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo implements PostRepository {
  final Map<int, List<String>> pages;
  FakeRepo(this.pages);

  @override
  Future<List<String>> fetchItems(int page, {int limit = 10}) async {
    return pages[page] ?? <String>[];
  }

  @override
  int refreshed = 0;
}

class FlakyRepo implements PostRepository {
  final Map<int, List<String>> pages;
  final Set<int> failOncePages;
  final Map<int, int> _calls = {};
  @override
  int refreshed = 0;
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

class RefreshFailingRepo implements PostRepository {
  final Map<int, List<String>> pages;
  int _refreshCount = 0;
  @override
  int refreshed = 0;

  RefreshFailingRepo(this.pages);

  @override
  Future<List<String>> fetchItems(int page, {int limit = 10}) async {
    if (page == 1) {
      refreshed++;
      _refreshCount++;

      if (_refreshCount == 3) {
        _refreshCount = 0;
        refreshed = 0; // Reset the refreshed counter too
        throw Exception('Refresh Failed');
      }
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

  testWidgets('refresh returns null on success', (tester) async {
    final repo = FakeRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
      2: List.generate(InfiniteController.pageSize, (i) => 'p2_item_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    // Initial load should have pageSize items plus loading sentinel
    var list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(list.last, isA<ItemLoading>());

    // Move to page 2
    controller.loadNextPage();
    await tester.pumpAndSettle();

    list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize * 2);
    expect(list.last, isA<ItemLoading>());

    // Refresh should return null on success
    final error = await controller.refresh();
    expect(error, isNull);
  });

  testWidgets('refresh returns error message on failure', (tester) async {
    final repo = RefreshFailingRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
      2: List.generate(InfiniteController.pageSize, (i) => 'p2_item_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    // Initial load
    var list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(list.last, isA<ItemLoading>());

    // Move to page 2
    controller.loadNextPage();
    await tester.pumpAndSettle();

    list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize * 2);
    expect(list.last, isA<ItemLoading>());

    // Trigger refresh failure by calling refresh 2 times
    await controller.refresh(); // 1st refresh
    final error = await controller.refresh(); // 2nd refresh should fail
    expect(error, isNotNull);
    expect(error, contains('Refresh Failed'));
  });

  testWidgets('refresh resets to page 1 even after multiple pages loaded',
      (tester) async {
    final repo = FakeRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
      2: List.generate(InfiniteController.pageSize, (i) => 'p2_item_$i'),
      3: List.generate(InfiniteController.pageSize, (i) => 'p3_item_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    // Load multiple pages
    controller.loadNextPage();
    await tester.pumpAndSettle();
    controller.loadNextPage();
    await tester.pumpAndSettle();

    var list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize * 3);
    expect(controller.pageNum.value, 3);

    // Refresh should reset to page 1
    await controller.refresh();
    await tester.pumpAndSettle();

    list = controller.items.peek();
    expect(controller.pageNum.value, 1);
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(list.last, isA<ItemLoading>());
  });

  testWidgets('refresh clears items and reloads page 1 data', (tester) async {
    final repo = FakeRepo({
      1: List.generate(InfiniteController.pageSize, (i) => 'p1_item_$i'),
      2: List.generate(InfiniteController.pageSize, (i) => 'p2_item_$i'),
    });
    final controller = InfiniteController(repo);

    await tester.pumpAndSettle();

    // Load page 2
    controller.loadNextPage();
    await tester.pumpAndSettle();

    var list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize * 2);
    expect(
        list.whereType<ItemData>().any((d) => d.value.startsWith('p2_item_')),
        isTrue);

    // Refresh should clear all items and reload page 1
    await controller.refresh();
    await tester.pumpAndSettle();

    list = controller.items.peek();
    expect(list.whereType<ItemData>().length, InfiniteController.pageSize);
    expect(
        list.whereType<ItemData>().any((d) => d.value.startsWith('p2_item_')),
        isFalse);
    expect(
        list.whereType<ItemData>().any((d) => d.value.startsWith('p1_item_')),
        isTrue);
  });
}
