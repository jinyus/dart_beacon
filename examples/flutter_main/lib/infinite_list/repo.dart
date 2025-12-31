part of 'infinite_list.dart';

class PostRepository {
  var refreshed = 0;
  Future<List<String>> fetchItems(int pageNum, {required int limit}) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate no more items
    if (pageNum > 5) return [];

    if (pageNum == 1) {
      refreshed++;
    }

    if (refreshed == 3) {
      refreshed = 0;
      throw Exception('Refresh Failed');
    }

    // randomly throw an error
    if (pageNum > 2 && math.Random().nextBool()) {
      throw Exception('Random Network Error');
    }

    final start = (pageNum - 1) * 10;

    return List.generate(10, (index) => 'Item ${start + index}');
  }
}
