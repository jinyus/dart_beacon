// ignore_for_file: invalid_return_type_for_catch_error

import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';
import 'package:state_beacon/state_beacon.dart';

import 'service.dart';

class CartController extends BeaconController {
  CartController(this._cartService);

  final CartService _cartService;

  // this is used to grey out the Add button of an item while it is being added to the cart
  // so the user cannot add it twice
  late final addingItems = B.family((int id) => B.writable(false));
  late final removingItems = B.family((int id) => B.writable(false));

  late final _cart = B.future(_cartService.loadProducts);

  // expose it as immutable so it can only be modified by the controller
  ReadableBeacon<AsyncValue<Cart>> get cart => _cart;

  Future<void> addItem(Product item) async {
    addingItems(item.id).value = true;
    await _cart.updateWith(() => _cartService.add(item));
    addingItems(item.id).value = false;
  }

  Future<void> removeItem(Product item) async {
    removingItems(item.id).value = true;
    await _cart.updateWith(() => _cartService.remove(item));
    removingItems(item.id).value = false;
  }
}
