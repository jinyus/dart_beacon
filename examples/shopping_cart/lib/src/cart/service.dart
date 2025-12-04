import 'package:shopping_cart/src/const.dart';
import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';

class CartService {
  final _items = <Product>[];

  Future<Cart> loadProducts() async {
    await Future<void>.delayed(k100ms * 10);
    return Cart(items: _items.toList());
  }

  Future<void> add(Product item) async {
    await Future<void>.delayed(k100ms * 10);
    _items.add(item);
  }

  Future<void> remove(Product item) async {
    await Future<void>.delayed(k100ms * 10);
    _items.remove(item);
  }
}
