import 'package:shopping_cart/src/const.dart';
import 'package:shopping_cart/src/models/product.dart';

class CartService {
  final _items = <Product>[];

  Future<List<Product>> loadProducts() =>
      Future.delayed(k100ms * 10, () => _items);

  Future<void> add(Product item) async => _items.add(item);

  Future<void> remove(Product item) async => _items.remove(item);
}
