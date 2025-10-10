import 'package:aplicacion_ventas/application/providers/cart_provider.dart';
import 'package:aplicacion_ventas/presentation/widgets/cart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart page that displays selected products with responsive layout adjustments.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro de compras'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final padding = EdgeInsets.symmetric(horizontal: constraints.maxWidth * (isWide ? 0.2 : 0.08));
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_shopping_cart_outlined, size: 72),
                    const SizedBox(height: 16),
                    Text('Tu carro está vacío', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Agrega productos desde el catálogo para continuar.',
                        textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: padding.copyWith(top: 24, bottom: 24),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) => CartItemTile(item: cart.items[index]),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: theme.textTheme.titleLarge),
                          Text('\$${cart.total.toStringAsFixed(0)}',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Proceder al pago'),
                      ),
                      TextButton(
                        onPressed: controller.clear,
                        child: const Text('Vaciar carro'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
