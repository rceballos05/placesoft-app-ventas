import 'dart:io';

import 'package:aplicacion_ventas/application/providers/cart_provider.dart';
import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';
import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/db/precios.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  final ScrollController _scrollController = ScrollController();
  final List<Producto> _productos = [];
  final NumberFormat _clpFormat =
      NumberFormat.currency(locale: 'es_CL', symbol: r'$', decimalDigits: 0);

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
    _loadMoreProducts(initial: true, resetCache: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScroll() async {
    if (!_scrollController.hasClients ||
        _isLoadingMore ||
        !_hasMore ||
        _isInitialLoading) {
      return;
    }
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      await _loadMoreProducts();
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
  }

  Future<void> _loadMoreProducts({bool initial = false, bool resetCache = false}) async {
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
      final nuevos = await obtenerProductosOffline(limit: _pageSize, offset: _offset);
      if (!mounted) {
        return;
      }
      final totalItems = _maeArticulosCache.length;
      final nextOffset = _offset + _pageSize;
      final hasMore = totalItems > nextOffset;
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

  Future<List<Producto>> obtenerProductosOffline({
    int limit = _pageSize,
    int offset = 0,
  }) async {
    await _ensureMaeArticulosCache();
    if (_databasePath == null) {
      throw Exception('Base de productos local no disponible');
    }

    final database = await openDatabase(_databasePath!, readOnly: true);
    try {
      final items = _maeArticulosCache.skip(offset).take(limit).toList();
      final List<Producto> productos = [];
      for (final MaeArticulos item in items) {
        final code = item.codigobarra?.trim();
        if (code == null || code.isEmpty) {
          continue;
        }
        final MaePrecios precioData = await DBPrecios.get(code, database: database);
        productos.add(
          Producto(
            codigobarra: code,
            descripcion: item.descripcion?.trim() ?? '',
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

  int _calculateCrossAxisCount(double width) {
    if (width >= 1100) {
      return 4;
    }
    if (width >= 750) {
      return 3;
    }
    return 2;
  }

  Future<void> _retryLoad() async {
    await _loadMoreProducts(initial: true, resetCache: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? [const Color(0xFF0D0B1A), Colors.deepPurple.shade900]
        : [const Color(0xFFE3F2FD), const Color(0xFFE8EAF6)];

    Widget bodyContent;
    if (_isInitialLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Error al cargar productos',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _retryLoad,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } else if (_productos.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'No hay productos disponibles',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sincroniza tu catálogo o intenta nuevamente más tarde.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    } else {
      bodyContent = LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: crossAxisCount >= 3 ? 0.7 : 0.68,
            ),
            itemCount: _productos.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _productos.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final producto = _productos[index];
              final domainProduct = _mapToDomain(producto);
              return _CatalogProductCard(
                producto: producto,
                domainProduct: domainProduct,
                currencyFormat: _clpFormat,
                isDark: isDark,
              );
            },
          );
        },
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catálogo',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Explora y agrega productos a tu carro incluso sin conexión.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white70
                            : theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: bodyContent,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        backgroundColor: Colors.transparent,
        color: isDark ? Colors.deepPurple.shade800 : const Color(0xFF4C53A5),
        animationDuration: const Duration(milliseconds: 300),
        index: 0,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.shopping_cart, color: Colors.white),
          Icon(Icons.people_alt, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 0) {
            return;
          }
          if (index == 1) {
            Navigator.of(context).pushNamed(CartPage.routeName);
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gestor de clientes disponible próximamente.')),
            );
          }
        },
      ),
    );
  }
}

class _CatalogProductCard extends ConsumerStatefulWidget {
  const _CatalogProductCard({
    required this.producto,
    required this.domainProduct,
    required this.currencyFormat,
    required this.isDark,
  });

  final Producto producto;
  final Product domainProduct;
  final NumberFormat currencyFormat;
  final bool isDark;

  @override
  ConsumerState<_CatalogProductCard> createState() => _CatalogProductCardState();
}

class _CatalogProductCardState extends ConsumerState<_CatalogProductCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _updateHover(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  void _updatePressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  void _addToCart() {
    ref.read(cartControllerProvider.notifier).add(widget.domainProduct);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.producto.descripcion} agregado al carro'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = _isHovered || _isPressed;
    final cardColor = widget.isDark ? const Color(0xFF1F1B2E) : Colors.white;
    final shadowColor = widget.isDark ? Colors.black.withOpacity(0.4) : Colors.black12;
    final formattedPrice = widget.currencyFormat.format(widget.producto.precio);

    return MouseRegion(
      onEnter: (_) => _updateHover(true),
      onExit: (_) => _updateHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(highlight ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: highlight ? 20 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _addToCart,
            onHighlightChanged: _updatePressed,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://picsum.photos/seed/${widget.producto.codigobarra}/400/400',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/img/producto.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if (widget.producto.descuento > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? Colors.deepPurple.shade400
                                  : Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-${widget.producto.descuento}%',
                              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.producto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isDark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formattedPrice,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isDark
                                ? Colors.deepPurpleAccent.shade100
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        color:
                            widget.isDark ? Colors.white : theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
