part of 'infinite_list.dart';

class PostRepository {
  Future<List<String>> fetchItems(int pageNum, {required int limit}) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    // simulate no more items
    if (pageNum > 5) return [];

    // randomly throw an error
    if (pageNum > 2 && math.Random().nextBool()) {
      throw Exception('Random Network Error');
    }

    final start = (pageNum - 1) * 10;

    return List.generate(10, (index) => 'Item ${start + index}');
  }
}
