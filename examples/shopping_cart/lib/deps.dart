import 'package:shopping_cart/src/cart/controller.dart';
import 'package:shopping_cart/src/cart/events.dart';
import 'package:shopping_cart/src/cart/service.dart';
import 'package:shopping_cart/src/catalog/controller.dart';
import 'package:shopping_cart/src/catalog/events.dart';
import 'package:shopping_cart/src/catalog/service.dart';
import 'package:state_beacon/state_beacon.dart';

// You can use your preferred dependency injection library to
// provide instrances to your widgets.
final cartServiceRef = Ref.scoped((_) => CartService());

final cartControllerRef = Ref.scoped(
  (ctx) => CartController(cartServiceRef(ctx))..dispatch(CartStarted()),
);

final catalogServiceRef = Ref.scoped((_) => CatalogService());

final catalogControllerRef = Ref.scoped(
  (ctx) {
    return CatalogController(catalogServiceRef(ctx))
      ..dispatch(CatalogEvent.started);
  },
);
