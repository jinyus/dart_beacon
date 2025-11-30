import 'package:shopping_cart/src/cart/controller.dart';
import 'package:shopping_cart/src/cart/service.dart';
import 'package:shopping_cart/src/catalog/controller.dart';
import 'package:shopping_cart/src/catalog/service.dart';
import 'package:state_beacon/state_beacon.dart';

final cartServiceRef = Ref.scoped((_) => CartService());

final cartControllerRef = Ref.scoped(
  (ctx) => CartController(cartServiceRef.read(ctx))..start(),
);

final catalogServiceRef = Ref.scoped((_) => CatalogService());

final catalogControllerRef = Ref.scoped(
  (ctx) {
    return CatalogController(catalogServiceRef.read(ctx))
      ..start();
  },
);