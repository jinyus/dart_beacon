import 'package:shopping_cart/src/const.dart';
import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';

class CartService {
  final _items = <Product>[];

  Future<Cart> loadProducts() async {
    await Future.delayed(k100ms * 10);
    return Cart(items: _items.toList());
  }

  Future<Cart> add(Product item) async {
    await Future.delayed(k100ms * 10);
    _items.add(item);
    return Cart(items: _items.toList());
  }

  Future<Cart> remove(Product item) async {
    await Future.delayed(k100ms * 10);
    _items.remove(item);
    return Cart(items: _items.toList());
  }
}
