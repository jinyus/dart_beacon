// ignore_for_file: invalid_return_type_for_catch_error

import 'package:shopping_cart/src/models/models.dart';
import 'package:state_beacon/state_beacon.dart';

import 'events.dart';
import 'service.dart';

class CartController {
  CartController(this._cartService);

  final CartService _cartService;

  late final _cart = Beacon.writable<AsyncValue<Cart>>(AsyncIdle());
  ReadableBeacon<AsyncValue<Cart>> get cart => _cart;

  Future<void> dispatch(CartEvent event) async {
    switch (event) {
      case CartStarted():
        _cart.value = AsyncLoading();
        _cart.value = await AsyncValue.tryCatch(
          () async => Cart(items: await _cartService.loadProducts()),
        );

      case CartItemAdded(:final item):
        if (_cart.value case AsyncData<Cart>(:final value)) {
          try {
            await _cartService.add(item);
            _cart.value = AsyncData(Cart(items: [...value.items, item]));
          } catch (e, s) {
            _cart.value = AsyncError(e, s);
          }
        }

      case CartItemRemoved(:final item):
        if (_cart.value case AsyncData<Cart>(:final value)) {
          try {
            await _cartService.remove(item);
            _cart.value = AsyncData(
              Cart(
                items: [...value.items]..remove(event.item),
              ),
            );
          } catch (e, s) {
            _cart.value = AsyncError(e, s);
          }
        }
    }
  }
}
