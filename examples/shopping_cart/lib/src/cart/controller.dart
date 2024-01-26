// ignore_for_file: invalid_return_type_for_catch_error

import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';
import 'package:state_beacon/state_beacon.dart';

import 'events.dart';
import 'service.dart';

class CartController {
  CartController(this._cartService);

  final CartService _cartService;

  late final _cart = Beacon.writable<AsyncValue<Cart>>(AsyncIdle());

  // these beacons are used to grey out the item while it is being removed/added;
  // thus preventing the user from clicking the item multiple times
  final _removingItem = Beacon.hashSet<Product>({});
  final _addingItem = Beacon.hashSet<Product>({});

  ReadableBeacon<Set<Product>> get removingIndex => _removingItem;
  ReadableBeacon<Set<Product>> get addingItem => _addingItem;
  ReadableBeacon<AsyncValue<Cart>> get cart => _cart;

  Future<void> dispatch(CartEvent event) async {
    switch (event) {
      case CartStarted():
        await _cart.tryCatch(() => _cartService.loadProducts());

      case CartItemAdded(:final item):
        _addingItem.add(item);
        await _cart.tryCatch(() => _cartService.add(item));
        _addingItem.remove(item);

      case CartItemRemoved(:final item):
        _removingItem.add(item);
        await _cart.tryCatch(() => _cartService.remove(item));
        _removingItem.remove(item);
    }
  }
}
