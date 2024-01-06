import 'package:lite_ref/lite_ref.dart';
import 'package:shopping_cart/src/cart/controller.dart';
import 'package:shopping_cart/src/cart/events.dart';
import 'package:shopping_cart/src/cart/service.dart';
import 'package:shopping_cart/src/catalog/controller.dart';
import 'package:shopping_cart/src/catalog/events.dart';
import 'package:shopping_cart/src/catalog/service.dart';

// You can use your preferred dependency injection library to
// provide instrances to your widgets.
final cartService = LiteRef(create: () => CartService());

final cartController = LiteRef(
  create: () => CartController(cartService())..dispatch(CartStarted()),
);

final catalogService = LiteRef(create: () => CatalogService());

final catalogController = LiteRef(
  create: () {
    return CatalogController(catalogService())..dispatch(CatalogEvent.started);
  },
);
