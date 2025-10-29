import 'dart:io';

import 'package:aplicacion_ventas/providers/cart_provider.dart';
import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';
import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/db/precios.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/pages/detalle.dart';
import 'package:aplicacion_ventas/presentation/pages/perfil.dart';
import 'package:aplicacion_ventas/presentation/widgets/busqueda_producto.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Home screen showing the catalogue with a modern, responsive layout.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const int _pageSize = 10;
  static const CurrencyFormatterSettings _clpSettings =
      CurrencyFormatterSettings(
    symbol: r'$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Producto> _productos = [];
  final List<MaeArticulos> _maeArticulosCache = [];

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _databasePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    BuscarProducto.configure(
        searcher: _searchProducts, currencySettings: _clpSettings);
    _scrollController.addListener(_onScroll);
    _loadMoreProducts(initial: true, resetCache: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingMore ||
        !_hasMore ||
        _isInitialLoading) {
      return;
    }
    final threshold = _scrollController.position.maxScrollExtent - 120;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts(
      {bool initial = false, bool resetCache = false}) async {
    if (_isLoadingMore || (!_hasMore && !initial)) {
      return;
    }

    if (initial) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
        _productos.clear();
        _offset = 0;
        _hasMore = true;
        if (resetCache) {
          _maeArticulosCache.clear();
          _databasePath = null;
        }
      });
    }

    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });

    try {
      await _ensureMaeArticulosCache();
      final nuevos =
          await obtenerProductosOffline(limit: _pageSize, offset: _offset);
      if (!mounted) {
        return;
      }
      final totalItems = _maeArticulosCache.length;
      final nextOffset = _offset + _pageSize;
      final hasMore = nextOffset < totalItems;
      setState(() {
        _productos.addAll(nuevos);
        _offset = nextOffset > totalItems ? totalItems : nextOffset;
        _hasMore = hasMore;
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isInitialLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _ensureMaeArticulosCache() async {
    if (_maeArticulosCache.isNotEmpty && _databasePath != null) {
      return;
    }

    final loginState = ref.read(loginControllerProvider);
    final path = await _resolveProductsDatabasePath(loginState);
    final database = await openDatabase(path, readOnly: true);
    try {
      final productos = await DBProductos.productos(database: database);
      _maeArticulosCache
        ..clear()
        ..addAll(productos);
      _databasePath = path;
    } finally {
      await database.close();
    }

    BuscarProducto.configure(
        searcher: _searchProducts, currencySettings: _clpSettings);
  }

  Future<List<Producto>> obtenerProductosOffline(
      {int limit = _pageSize, int offset = 0}) async {
    await _ensureMaeArticulosCache();
    final items = _maeArticulosCache.skip(offset).take(limit).toList();
    return _mapMaeArticulos(items);
  }

  Future<List<Producto>> _searchProducts(String query) async {
    await _ensureMaeArticulosCache();
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _mapMaeArticulos(_maeArticulosCache.take(_pageSize).toList());
    }

    final matches = _maeArticulosCache
        .where((item) {
          final description = item.descripcion?.toLowerCase() ?? '';
          final code = item.codigobarra?.toLowerCase() ?? '';
          return description.contains(normalized) || code.contains(normalized);
        })
        .take(30)
        .toList();

    return _mapMaeArticulos(matches);
  }

  Future<List<Producto>> _mapMaeArticulos(List<MaeArticulos> items) async {
    if (items.isEmpty) {
      return const <Producto>[];
    }
    final path = _databasePath;
    if (path == null) {
      throw Exception('Base de productos local no disponible');
    }

    final database = await openDatabase(path, readOnly: true);
    try {
      final productos = <Producto>[];
      for (final MaeArticulos item in items) {
        final code = item.codigobarra?.trim();
        if (code == null || code.isEmpty) {
          continue;
        }
        final MaePrecios precioData =
            await DBPrecios.get(code, database: database);
        productos.add(
          Producto(
            codigobarra: code,
            descripcion: (item.descripcion ?? '').trim(),
            descuento: item.descuento?.toInt() ?? 0,
            precio: precioData.precioVenta.toInt(),
          ),
        );
      }
      return productos;
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
      if (await file.exists() &&
          (path.contains('productos') || path.contains('_local00'))) {
        return path;
      }
    }

    throw Exception('Base de productos local no disponible');
  }

  void _retryLoad() {
    _loadMoreProducts(initial: true, resetCache: true);
  }

  Future<void> _addProductToCart(Producto producto) async {
    final domainProduct = _mapToDomain(producto);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(cartProvider.notifier).addProductFromCatalog(domainProduct);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('${producto.descripcion} agregado al carro'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      final latestState = ref.read(cartProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(latestState.errorMessage ?? 'No se pudo agregar el producto.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openSearch(BuildContext context) async {
    final result = await showSearch<Producto?>(
      context: context,
      delegate: BuscarProducto(),
      query: _searchController.text,
    );
    if (!mounted || result == null) {
      return;
    }
    _addProductToCart(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const navHeight = 60.0;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0E0E11) : const Color(0xFFF1F4FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final crossAxisCount = isWide ? 3 : 2;
            final aspectRatio = isWide ? 0.72 : 0.74;

            Widget content;
            if (_isInitialLoading) {
              content = const Center(child: CircularProgressIndicator());
            } else if (_errorMessage != null) {
              content =
                  _ErrorView(onRetry: _retryLoad, message: _errorMessage!);
            } else if (_productos.isEmpty) {
              content = const _EmptyCatalogView();
            } else {
              content = GridView.builder(
                key: const ValueKey('catalog-grid'),
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: navHeight + 16,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _productos.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _productos.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final producto = _productos[index];
                  return _ProductCard(
                    producto: producto,
                    currencySettings: _clpSettings,
                    onAddToCart: () => _addProductToCart(producto),
                  );
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catálogo',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explora y agrega productos a tu carro incluso sin conexión.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? Colors.white70
                              : theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _openSearch(context),
                              decoration: InputDecoration(
                                hintText: 'Buscar productos…',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1A1B22)
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openSearch(context),
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(110, 48),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: content,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: navHeight,
        backgroundColor: Colors.transparent,
        color: isDark ? Colors.deepPurple.shade800 : const Color(0xFF4C53A5),
        animationDuration: const Duration(milliseconds: 300),
        index: 0,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed(CartPage.routeName);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(Perfil.routeName);
          }
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.producto,
    required this.currencySettings,
    required this.onAddToCart,
  });

  final Producto producto;
  final CurrencyFormatterSettings currencySettings;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final priceText =
        CurrencyFormatter.format(producto.precio, currencySettings);

    return Card(
      color: isDark ? const Color(0xFF1A1B22) : Colors.white,
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Detalle(
                codigo: producto.codigobarra, // ← aquí le pasas el código
                busquedaInicial: producto.descripcion, // opcional
                fromBusqueda: false, // o true según el caso
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Imagen un poco más chica
            Expanded(
              flex: 5, // antes era 6
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      'https://picsum.photos/seed/${producto.codigobarra}/400/400',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/img/producto.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 🔹 Botón del carrito más grande
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: isDark
                          ? Colors.deepPurpleAccent.shade100.withOpacity(0.9)
                          : theme.colorScheme.primary.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAddToCart,
                        child: const Padding(
                          padding: EdgeInsets.all(10), // antes 8
                          child: Icon(
                            LineAwesomeIcons.shopping_cart,
                            size: 22, // antes 20
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Contenido más compacto
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13, // más pequeño
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      priceText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // ajustado
                        color: isDark
                            ? Colors.deepPurpleAccent.shade100
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Error al cargar productos',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCatalogView extends StatelessWidget {
  const _EmptyCatalogView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'No hay productos disponibles',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sincroniza tu catálogo o intenta nuevamente más tarde.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
