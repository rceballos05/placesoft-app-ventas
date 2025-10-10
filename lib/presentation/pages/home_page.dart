import 'dart:io';

import 'package:aplicacion_ventas/application/providers/cart_provider.dart';
import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';
import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/db/precios.dart';
import 'package:aplicacion_ventas/core/utils/screen_utils.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Home screen showing the catalogue with adaptive layouts.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const int _initialLimit = 10;

  late Future<List<Producto>> _productsFuture;
  int _currentLimit = _initialLimit;

  @override
  void initState() {
    super.initState();
    _productsFuture = _obtenerProductosOffline(limit: _initialLimit);
  }

  Future<List<Producto>> _obtenerProductosOffline({required int limit}) async {
    final loginState = ref.read(loginControllerProvider);
    final databasePath = await _resolveProductsDatabasePath(loginState);
    final database = await openDatabase(databasePath, readOnly: true);
    try {
      final maeArticulos = await DBProductos.productos(database: database, limit: limit);
      final List<Producto> products = [];
      for (final MaeArticulos item in maeArticulos) {
        final code = item.codigobarra?.trim();
        if (code == null || code.isEmpty) {
          continue;
        }
        final precioData = await DBPrecios.get(code, database: database);
        products.add(
          Producto(
            codigobarra: code,
            descripcion: item.descripcion?.trim() ?? '',
            descuento: item.descuento?.toInt() ?? 0,
            precio: precioData.precioVenta.toInt(),
          ),
        );
      }
      return products;
    } finally {
      await database.close();
    }
  }

  Product _mapToDomain(Producto producto) {
    return Product(
      code: producto.codigobarra,
      description: producto.descripcion,
      price: producto.precio.toDouble(),
      discount: producto.descuento.toDouble(),
      imageUrl: 'https://picsum.photos/seed/${producto.codigobarra}/400/400',
    );
  }

  Future<String> _resolveProductsDatabasePath(LoginState state) async {
    final candidates = <String>[];
    final cached = state.databasePath;
    if (cached != null && cached.isNotEmpty) {
      candidates.add(cached);
    }

    final prefix = state.user?.prefijo;
    final normalizedPrefix = prefix?.trim().toLowerCase();
    if (normalizedPrefix != null && normalizedPrefix.isNotEmpty) {
      final databasesPath = await getDatabasesPath();
      candidates
        ..add(p.join(databasesPath, normalizedPrefix, 'productos.db'))
        ..add(p.join(databasesPath, '${normalizedPrefix}_local00.db'));
    }

    for (final path in candidates) {
      if (path.isEmpty) continue;
      final file = File(path);
      if (await file.exists() && (path.contains('productos') || path.contains('_local00'))) {
        return path;
      }
    }

    throw Exception('Base de productos local no disponible');
  }

  Future<void> _refresh() async {
    final future = _obtenerProductosOffline(limit: _currentLimit);
    setState(() {
      _productsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildGrid(List<Producto> items, bool isWide) {
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
            (context, index) => ProductCard(product: _mapToDomain(items[index])),
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
          return FutureBuilder<List<Producto>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              final isLoading = snapshot.connectionState == ConnectionState.waiting;
              final hasError = snapshot.hasError;
              final products = snapshot.data ?? const <Producto>[];

              Widget sliverContent;
              if (isLoading) {
                sliverContent = const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (hasError) {
                sliverContent = SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error al cargar productos: ${snapshot.error}', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _refresh,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (products.isEmpty) {
                sliverContent = const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No hay productos disponibles.')),
                );
              } else {
                sliverContent = buildGrid(products, isWide);
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                    sliverContent,
                  ],
                ),
              );
            },
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
