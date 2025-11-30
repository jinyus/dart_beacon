// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_cart/deps.dart';
import 'package:shopping_cart/src/app.dart';
import 'package:shopping_cart/src/cart/controller.dart';
import 'package:shopping_cart/src/catalog/controller.dart';
import 'package:shopping_cart/src/catalog/view.dart';
import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';
import 'package:state_beacon/state_beacon.dart';

final products = [
  Product(id: 1, name: 'Product 1', price: 1, color: Colors.white),
  Product(id: 2, name: 'Product 2', price: 2, color: Colors.black),
];

final _sampleCart = Cart(items: []);

final _sampleCatalog = Catalog([
  Product(id: 1, name: 'Product 1', price: 1, color: Colors.white),
  Product(id: 2, name: 'Product 2', price: 2, color: Colors.black),
]);

final _addingItem = Beacon.family((int id) => Beacon.writable(false));
final _removingItem = Beacon.family((int id) => Beacon.writable(false));

final _mockCart = Beacon.writable<AsyncValue<Cart>>(AsyncLoading());
final _mockCatalog = Beacon.writable<AsyncValue<Catalog>>(AsyncLoading());

class MockCartController extends Mock implements CartController {}

class MockCatalogController extends Mock implements CatalogController {}

void main() {
  final cartC = MockCartController();
  final catalogC = MockCatalogController();

  testWidgets('Full app test', (WidgetTester tester) async {
    when(() => cartC.cart).thenReturn(_mockCart);
    when(() => cartC.addingItems).thenReturn(_addingItem);
    when(() => cartC.removingItems).thenReturn(_removingItem);
    when(() => catalogC.catalog).thenReturn(_mockCatalog);

    await tester.pumpWidget(LiteRefScope(
      overrides: {
        cartControllerRef.overrideWith((_) => cartC),
        catalogControllerRef.overrideWith((_) => catalogC),
      },
      child: const MyApp(),
    ));

    // catalog loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // simulate catalog error
    _mockCatalog.value = AsyncError('error', StackTrace.empty);

    await tester.pump();

    expect(find.text('Something went wrong!'), findsOneWidget);

    // simulate catalog data
    _mockCatalog.value = AsyncData(_sampleCatalog);

    await tester.pump();

    expect(find.byType(CatalogGridItem), findsExactly(2));

    // simulate cart error
    _mockCart.value = AsyncError('error', StackTrace.empty);

    await tester.pump();

    // add to cart buttons should display error
    expect(find.text('Something went wrong!'), findsExactly(2));

    // simulate cart loading
    _mockCart.value = AsyncIdle();

    await tester.pump();

    // add to cart buttons should display loading
    expect(find.byType(CircularProgressIndicator), findsExactly(2));

    _mockCart.value = AsyncData(_sampleCart);

    await tester.pumpAndSettle();

    // add to cart buttons should display add
    expect(find.text('ADD'), findsExactly(2));

    // simulate adding item to cart
    _sampleCart.items.add(products[0]);

    _mockCart.value = AsyncLoading();

    BeaconScheduler.flush();

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsExactly(2));

    _mockCart.value = AsyncData(_sampleCart);

    await tester.pumpAndSettle();

    // one button should have ADD and the other should have a check
    expect(find.text('ADD'), findsOneWidget);

    // added item
    expect(find.byIcon(Icons.check), findsOneWidget);

    // cart item count
    expect(find.text('1'), findsOneWidget);

    // find cart button by key
    final cartButton = find.byKey(const Key('cart_button'));

    expect(cartButton, findsOneWidget);

    // tap cart button
    await tester.tap(cartButton);

    // wait for the navigation transition to finish
    await tester.pumpAndSettle();

    // item in the cart
    expect(find.byType(ListTile), findsOneWidget);

    _mockCart.value = AsyncLoading();

    BeaconScheduler.flush();

    await tester.pump();

    // total and list
    expect(find.byType(CircularProgressIndicator), findsExactly(2));

    expect(find.byType(ListTile), findsNothing);

    _sampleCart.items.add(products[1]);

    _mockCart.value = AsyncData(_sampleCart);

    await tester.pumpAndSettle();

    // total and list
    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.byType(ListTile), findsNWidgets(2));

    // total
    expect(find.text('\$${_sampleCart.totalPrice}'), findsOneWidget);

    _mockCart.value = AsyncError('error', StackTrace.empty);

    BeaconScheduler.flush();

    await tester.pump();

    expect(find.text('Something went wrong!'), findsExactly(2));
  });
}
