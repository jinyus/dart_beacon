import 'package:flutter/material.dart';
import 'package:shopping_cart/src/const.dart';
import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';

class CatalogService {
  Future<Catalog> load() => Future<void>.delayed(
      k100ms * 8,
      () => Catalog([
            Product(price: 42, id: 0, color: Colors.red, name: 'Red Car'),
            Product(price: 53, id: 1, color: Colors.green, name: 'Green Car'),
            Product(price: 58, id: 2, color: Colors.blue, name: 'Blue Car'),
            Product(price: 32, id: 3, color: Colors.yellow, name: 'Yellow Car'),
            Product(price: 93, id: 4, color: Colors.purple, name: 'Purple Car'),
            Product(
                price: 102, id: 5, color: Colors.orange, name: 'Orange Car'),
            Product(price: 77, id: 6, color: Colors.teal, name: 'Teal Car'),
            Product(price: 81, id: 7, color: Colors.pink, name: 'Pink Car'),
            Product(price: 49, id: 8, color: Colors.cyan, name: 'Cyan Car'),
            Product(price: 29, id: 9, color: Colors.lime, name: 'Lime Car'),
            Product(
                price: 84, id: 10, color: Colors.indigo, name: 'Indigo Car'),
            Product(price: 90, id: 11, color: Colors.amber, name: 'Amber Car'),
            Product(price: 104, id: 12, color: Colors.brown, name: 'Brown Car'),
            Product(price: 30, id: 13, color: Colors.grey, name: 'Grey Car'),
            Product(price: 62, id: 15, color: Colors.black, name: 'Black Car'),
          ]));
}
