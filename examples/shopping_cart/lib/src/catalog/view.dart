import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shopping_cart/src/cart/controller.dart';
import 'package:shopping_cart/src/cart/events.dart';
import 'package:shopping_cart/src/catalog/events.dart';
import 'package:shopping_cart/src/models/product.dart';
import 'package:state_beacon/state_beacon.dart';
import 'controller.dart';

class CatalogView extends StatelessWidget {
  const CatalogView(
      {super.key, required this.controller, required this.cartController});

  static const routeName = '/';

  final CatalogController controller;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final state = controller.catalog.watch(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cols = _getCrossAxisCount(screenWidth);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          controller.dispatch(CatalogEvent.refresh);
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: CustomScrollView(
            slivers: [
              CatalogAppBar(cartController: cartController),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              switch (state) {
                AsyncError() => const SliverFillRemaining(
                    child: Text('Something went wrong!'),
                  ),
                AsyncData(value: final catalog) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => CatalogGridItem(
                        catalog.getByPosition(index),
                        cartController: cartController,
                      ),
                      childCount: catalog.products.length,
                    ),
                  ),
                _ => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogGridItem extends StatelessWidget {
  const CatalogGridItem(this.item, {super.key, required this.cartController});

  final Product item;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.titleLarge;
    return Container(
      decoration: BoxDecoration(
        color: item.color.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.name, style: textTheme),
            Icon(
              size: 80,
              Icons.directions_car_sharp, // Replace with actual item icon
              color: item.color,
            ),
            AddButton(item: item, cartController: cartController),
          ],
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton(
      {required this.item, super.key, required this.cartController});

  final Product item;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = cartController.cart.watch(context);

    return switch (state) {
      AsyncError() => const Text('Something went wrong!'),
      AsyncData() || AsyncLoading() when state.lastData != null => Builder(
          builder: (context) {
            final cart = state.lastData!;
            final isInCart = cart.items.contains(item);
            final isAdding =
                cartController.addingItem.watch(context).contains(item);
            final btnChild = isAdding
                ? const CircularProgressIndicator()
                : const Text('ADD');

            return TextButton(
              style: TextButton.styleFrom(
                  disabledForegroundColor: theme.primaryColor,
                  backgroundColor: theme.cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(100, 50)),
              onPressed: isInCart || isAdding
                  ? null
                  : () => cartController.dispatch(CartItemAdded(item)),
              child: isInCart
                  ? const Icon(Icons.check, semanticLabel: 'ADDED')
                  : btnChild,
            );
          },
        ),
      _ => const CircularProgressIndicator(),
    };
  }
}

class CatalogAppBar extends StatelessWidget {
  const CatalogAppBar({super.key, required this.cartController});

  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    final cart = cartController.cart.watch(context);
    final count = cart.lastData?.items.length ?? 0;

    return SliverAppBar(
      title: const Text('Catalog'),
      floating: true,
      pinned: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
            ),
            if (count > 0)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

int _getCrossAxisCount(double width) {
  if (width < 600) {
    // Mobile
    return 1;
  } else if (width < 1200) {
    // Tablet
    return 3;
  } else {
    // Desktop
    return 5;
  }
}
