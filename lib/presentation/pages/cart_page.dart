import 'package:aplicacion_ventas/providers/cart_provider.dart';
import 'package:aplicacion_ventas/presentation/widgets/cart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart page that displays selected products with responsive layout adjustments.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static const routeName = '/cart';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final controller = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    if (cart.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carro de compras')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro de compras'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final padding = EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * (isWide ? 0.2 : 0.08),
          );

          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_shopping_cart_outlined, size: 72),
                    const SizedBox(height: 16),
                    Text('Tu carro está vacío',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Agrega productos desde el catálogo para continuar.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (cart.errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        cart.errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: padding.copyWith(top: 24, bottom: 24),
            child: Column(
              children: [
                if (cart.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: theme.colorScheme.onErrorContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cart.errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) =>
                        CartItemTile(line: cart.items[index]),
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
                          Text(
                            '\$${cart.total.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: cart.isSaving
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final wasSaved =
                                    await controller.saveCartToVenta();
                                final latestState = ref.read(cartProvider);
                                if (wasSaved) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Nota de pedido generada correctamente.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else if (latestState.errorMessage != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(latestState.errorMessage!),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                        child: cart.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Proceder al pago'),
                      ),
                      TextButton(
                        onPressed: cart.isSaving ? null : controller.clearCart,
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
