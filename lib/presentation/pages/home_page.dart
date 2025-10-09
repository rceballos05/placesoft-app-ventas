import 'package:aplicacion_ventas/application/providers/cart_provider.dart';
import 'package:aplicacion_ventas/application/providers/product_provider.dart';
import 'package:aplicacion_ventas/core/utils/screen_utils.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home screen showing the catalogue with adaptive layouts.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productControllerProvider);
    final products = state.products;
    final theme = Theme.of(context);

    Future<void> refresh() async {
      await ref.read(productControllerProvider.notifier).loadProducts();
    }

    Widget buildGrid(List<Product> items, bool isWide) {
      final crossAxisCount = isWide ? 4 : 2;
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: context.width * (isWide ? 0.06 : 0.04)),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isWide ? 0.85 : 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ProductCard(product: items[index]),
            childCount: items.length,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.of(context).pushNamed(CartPage.routeName),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return RefreshIndicator(
            onRefresh: refresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: context.horizontalPadding(isWide ? 0.2 : 0.08).copyWith(top: 24, bottom: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar productos',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage!, style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: refresh,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No hay productos disponibles.')),
                  )
                else
                  buildGrid(products, isWide),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed(CartPage.routeName);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Carro'),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final cart = ref.watch(cartControllerProvider);
          if (cart.items.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).pushNamed(CartPage.routeName),
            label: Text('Ver carro (${cart.items.length})'),
            icon: const Icon(Icons.shopping_cart_checkout),
          );
        },
      ),
    );
  }
}
