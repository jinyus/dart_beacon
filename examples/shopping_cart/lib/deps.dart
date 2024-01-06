import 'package:lite_ref/lite_ref.dart';
import 'package:shopping_cart/src/cart/controller.dart';
import 'package:shopping_cart/src/cart/events.dart';
import 'package:shopping_cart/src/cart/service.dart';
import 'package:shopping_cart/src/catalog/controller.dart';
import 'package:shopping_cart/src/catalog/events.dart';
import 'package:shopping_cart/src/catalog/service.dart';

// You can use your preferred dependency injection library to
// provide instrances to your widgets.
final cartService = Ref.singleton(create: () => CartService());

final cartController = Ref.singleton(
  create: () => CartController(cartService())..dispatch(CartStarted()),
);

final catalogService = Ref.singleton(create: () => CatalogService());

final catalogController = Ref.singleton(
  create: () {
    return CatalogController(catalogService())..dispatch(CatalogEvent.started);
  },
);
