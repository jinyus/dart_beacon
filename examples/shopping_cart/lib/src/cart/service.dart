import 'package:shopping_cart/src/const.dart';
import 'package:shopping_cart/src/models/product.dart';

class CartService {
  final _items = <Product>[];

  Future<List<Product>> loadProducts() =>
      Future.delayed(k100ms * 10, () => _items.toList());

  Future<List<Product>> add(Product item) async {
    await Future.delayed(k100ms * 10);
    _items.add(item);
    return _items.toList();
  }

  Future<List<Product>> remove(Product item) async {
    await Future.delayed(k100ms * 10);
    _items.remove(item);
    return _items.toList();
  }
}
