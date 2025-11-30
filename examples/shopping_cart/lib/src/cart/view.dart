import 'package:flutter/material.dart';
import 'package:shopping_cart/deps.dart';
import 'package:state_beacon/state_beacon.dart';

const loadingIndicator = Center(child: CircularProgressIndicator());

class CartView extends StatelessWidget {
  const CartView({super.key});

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Cart')),
      body: ColoredBox(
        color: Colors.grey.shade800,
        child: const Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CartList(),
              ),
            ),
            Divider(height: 4, color: Colors.black),
            CartTotal(),
          ],
        ),
      ),
    );
  }
}

class CartList extends StatelessWidget {
  const CartList({super.key});

  @override
  Widget build(BuildContext context) {
    final itemNameStyle = Theme.of(context).textTheme.titleLarge;
    final controller = cartControllerRef(context);

    final state = controller.cart.watch(context);

    return switch (state) {
      AsyncData() ||
      AsyncLoading() when state.lastData != null =>
        ListView.separated(
          itemCount: state.lastData!.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = state.lastData!.items.elementAtOrNull(index);
            if (item == null) {
              return const SizedBox.shrink();
            }
            final isRemoving = controller.removingItems(item.id).watch(context);

            return Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isRemoving ? Colors.grey.shade700 : Colors.white,
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: item.color.withAlpha(50),
                  leading: const Icon(Icons.directions_car_sharp),
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.name, style: itemNameStyle),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: isRemoving
                        ? null
                        : () {
                            controller.removeItem(item);
                          },
                  ),
                ),
              ),
            );
          },
        ),
      AsyncError() => const Text('Something went wrong!'),
      _ => loadingIndicator,
    };
  }
}

class CartTotal extends StatelessWidget {
  const CartTotal({super.key});

  @override
  Widget build(BuildContext context) {
    final hugeStyle = Theme.of(context)
        .textTheme
        .displayLarge
        ?.copyWith(fontSize: 48)
        .copyWith(color: Colors.white);

    final state = cartControllerRef(context).cart.watch(context);

    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            switch (state) {
              AsyncData() ||
              AsyncLoading() when state.lastData != null =>
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '\$${state.lastData!.totalPrice}',
                    style: hugeStyle,
                  ),
                ),
              AsyncError() => const Text('Something went wrong!'),
              _ => loadingIndicator,
            },
            const SizedBox(width: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Buying not supported yet.')),
                );
              },
              child: const Text('BUY'),
            ),
          ],
        ),
      ),
    );
  }
}
