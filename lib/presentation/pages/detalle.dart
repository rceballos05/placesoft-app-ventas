import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:aplicacion_ventas/application/providers/cart_provider.dart';
import 'package:aplicacion_ventas/application/providers/login_provider.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart' as domain;
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/presentation/pages/cart_page.dart';
import 'package:aplicacion_ventas/presentation/widgets/busqueda_producto.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Detalle extends ConsumerStatefulWidget {
  const Detalle({
    super.key,
    this.codigo,
    this.busquedaInicial,
    this.fromBusqueda = false,
  });

  final String? codigo;
  final String? busquedaInicial;
  final bool fromBusqueda;

  static const routeName = '/detalle';

  @override
  ConsumerState<Detalle> createState() => _DetalleState();
}

class _DetalleState extends ConsumerState<Detalle> {
  static const _currencySettings = CurrencyFormatterSettings(
    symbol: r'$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _discountController =
      TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();

  late Future<_ProductDetail> _detailFuture;

  Producto? _producto;
  String? _imageUrl;
  int _quantity = 1;
  int _unitPrice = 0;
  double _productMaxDiscount = 0;
  double _maxDiscount = 0;
  double _discountPercent = 0;
  int _subtotal = 0;
  int _discountValue = 0;
  int _total = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<_ProductDetail> _loadDetail() async {
    final code = widget.codigo?.trim();
    if (code == null || code.isEmpty) {
      throw Exception('Código de producto no disponible');
    }

    final loginState = ref.read(loginControllerProvider);
    if (loginState.user == null) {
      developer.log('Cargando detalle de producto sin usuario autenticado',
          name: 'Detalle');
    }
    final databasePath = await _resolveProductsDatabasePath(loginState);
    final database = await openDatabase(databasePath, readOnly: true);
    try {
      final productRows = await database.query(
        'mae_articulos_00',
        where: 'codigobarra = ?',
        whereArgs: [code],
        limit: 1,
      );

      if (productRows.isEmpty) {
        throw Exception('Producto no encontrado');
      }

      final productoMae = MaeArticulos.fromMap(productRows.first);
      final priceData = await DBPrecios.get(
        code,
        database: database,
      );

      final descripcion = (productoMae.descripcion ?? '').trim();
      final descuentoPermitido = productoMae.descuento ?? 0;
      final precio = priceData.precioVenta.toInt();

      final detalle = _ProductDetail(
        producto: Producto(
          codigobarra: code,
          descripcion:
              descripcion.isEmpty ? 'Producto sin nombre' : descripcion,
          precio: precio,
          descuento: descuentoPermitido.toInt(),
        ),
        imageUrl: 'https://picsum.photos/seed/$code/600/600',
        maxDiscount: descuentoPermitido.toDouble(),
      );

      if (mounted) {
        final user = loginState.user;
        final effectiveMaxDiscount = user != null
            ? min(detalle.maxDiscount, user.maxDcto)
            : detalle.maxDiscount;
        if (user == null) {
          developer.log('No hay usuario para limitar descuento; se usará el '
              'valor del producto (${detalle.maxDiscount})',
              name: 'Detalle');
        }
        setState(() {
          _producto = detalle.producto;
          _imageUrl = detalle.imageUrl;
          _unitPrice = max(0, detalle.producto.precio);
          _productMaxDiscount = max(0, detalle.maxDiscount);
          _maxDiscount = max(0, effectiveMaxDiscount);
          _quantity = 1;
          _discountPercent = 0;
          _quantityController.text = '1';
          _discountController.text = '0';
        });
        _recalculateTotals();
      }

      return detalle;
    } finally {
      await database.close();
    }
  }

  Future<String> _resolveProductsDatabasePath(LoginState state) async {
    final candidates = <String>[];
    final cached = state.databasePath;
    if (cached != null && cached.isNotEmpty) {
      candidates.add(cached);
    }

    final userPrefix = state.user?.prefijo;
    if (userPrefix == null || userPrefix.isEmpty) {
      developer.log('Resolviendo base de productos sin prefijo de usuario',
          name: 'Detalle');
    }
    final prefix = userPrefix?.trim().toLowerCase();
    if (prefix != null && prefix.isNotEmpty) {
      final databasesPath = await getDatabasesPath();
      candidates
        ..add(p.join(databasesPath, prefix, 'productos.db'))
        ..add(p.join(databasesPath, '${prefix}_local00.db'));
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

  void _recalculateTotals() {
    final subtotal = _quantity * _unitPrice;
    final appliedDiscount = subtotal <= 0
        ? 0.0
        : min(_discountPercent.clamp(0, _maxDiscount), _maxDiscount);
    final discountValue = (subtotal * (appliedDiscount / 100)).round();
    final total = max(0, subtotal - discountValue);

    setState(() {
      _subtotal = subtotal;
      _discountPercent = appliedDiscount.toDouble();
      _discountValue = discountValue;
      _total = total;
    });
  }

  void _increaseQuantity() {
    if (_isSaving) return;
    _quantity = min(_quantity + 1, 999);
    _quantityController.text = _quantity.toString();
    _recalculateTotals();
  }

  void _decreaseQuantity() {
    if (_isSaving) return;
    if (_quantity <= 1) return;
    _quantity = max(1, _quantity - 1);
    _quantityController.text = _quantity.toString();
    _recalculateTotals();
  }

  void _onQuantityChanged(String value) {
    if (_isSaving) return;
    if (value.trim().isEmpty) {
      return;
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      _quantityController.text = _quantity.toString();
      return;
    }
    _quantity = parsed.clamp(1, 999);
    if (_quantity.toString() != value) {
      _quantityController.text = _quantity.toString();
      _quantityController.selection =
          TextSelection.collapsed(offset: _quantityController.text.length);
    }
    _recalculateTotals();
  }

  void _onDiscountChanged(String value) {
    if (_isSaving) return;
    final trimmed = value.trim();
    final parsed =
        trimmed.isEmpty ? 0.0 : double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null) {
      _discountController.text = _discountPercent.toStringAsFixed(0);
      _discountController.selection =
          TextSelection.collapsed(offset: _discountController.text.length);
      return;
    }
    final maxAllowedDiscount = min(_maxDiscount, 100);
    final capped = parsed.clamp(0, maxAllowedDiscount);
    if (capped != parsed) {
      _discountController.text = capped.toStringAsFixed(0);
      _discountController.selection =
          TextSelection.collapsed(offset: _discountController.text.length);
      final maxLabel = maxAllowedDiscount == _maxDiscount
          ? _maxDiscount.toStringAsFixed(0)
          : '100';
      _showError('El descuento debe estar entre 0% y $maxLabel%.');
    }
    _discountPercent = capped.toDouble();
    _recalculateTotals();
  }

  Future<void> _retry() async {
    setState(() {
      _detailFuture = _loadDetail();
    });
  }

  Future<void> _addToCart() async {
    final detail = _producto;
    if (detail == null || _isSaving) {
      return;
    }
    if (_quantity <= 0) {
      _showError('La cantidad debe ser al menos 1.');
      return;
    }
    if (_total <= 0) {
      _showError('El total debe ser mayor que cero.');
      return;
    }

    final loginState = ref.read(loginControllerProvider);
    final user = loginState.user;
    if (user == null) {
      developer.log('Intento de agregar producto sin sesión activa',
          name: 'Detalle');
      _showError('La sesión ha expirado. Inicia sesión nuevamente.');
      return;
    }

    final cart = ref.read(cartControllerProvider);
    if (cart.items.any((item) => item.product.code == detail.codigobarra)) {
      _showError('El producto ya fue agregado al carrito.');
      return;
    }
    if (cart.items.length >= 32) {
      _showError('Se alcanzó el máximo de 32 productos en el carro.');
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      final now = DateTime.now();
      final lineNumber = await DBRollo.getNextLineNumber();
      final unitPriceWithDiscount = _quantity > 0
          ? (_total / _quantity).roundToDouble()
          : _total.toDouble();
      final transactionDate = now.toIso8601String();
      final time = _formatTime(now);
      final rut = user.rut;

      final rollo = LocalRollo(
        local: '00',
        cajaDoc: '00',
        lineaVenta: lineNumber.toDouble(),
        rutCajero: rut,
        artCantidad: _quantity.toDouble(),
        artCodigo: detail.codigobarra,
        artDescripcion: detail.descripcion,
        artDescuento: _discountPercent,
        artPrecio: unitPriceWithDiscount,
        totalLinea: _total.toDouble(),
        rutVendedor: rut,
        fechaTransaccion: transactionDate,
        horaTransaccion: time,
        tipoVenta: 'NPE',
        codImpuesto: '0000',
        porceImpuesto: 0,
      );

      await DBRollo.insert(rollo);
      final notes = _notesController.text.trim();
      if (notes.isNotEmpty) {
        await DBRolloObservaciones.insert(
          LocalRolloObservaciones(
            codigo: detail.codigobarra,
            fecha: transactionDate,
            caja: '00',
            observaciones: notes,
          ),
        );
      }

      final domainProduct = domain.Product(
        code: detail.codigobarra,
        description: detail.descripcion,
        price: unitPriceWithDiscount,
        discount: _discountPercent,
        imageUrl: _imageUrl ?? '',
      );
      final controller = ref.read(cartControllerProvider.notifier);
      for (var i = 0; i < _quantity; i++) {
        controller.add(domainProduct);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Producto agregado al carrito'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      Navigator.pushNamed(context, CartPage.routeName);
    } catch (error) {
      if (!mounted) return;
      _showError(
          'No se pudo agregar el producto al carrito. Inténtalo nuevamente.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atención'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (!mounted) {
        return;
      }
      if (next.user == null) {
        developer.log('Estado de login sin usuario al actualizar descuentos',
            name: 'Detalle');
      }
      _updateDiscountLimits();
    });

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4C53A5), Color(0xFF6A75E1)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                onBackPressed: _handleBack,
              ),
              Expanded(
                child: FutureBuilder<_ProductDetail>(
                  future: _detailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return _ErrorView(
                        message:
                            'No se pudo cargar la información del producto.',
                        onRetry: _retry,
                      );
                    }
                    if (!snapshot.hasData) {
                      return _ErrorView(
                        message: 'El producto no está disponible.',
                        onRetry: _retry,
                      );
                    }
                    final detail = snapshot.data!;
                    return AnimatedOpacity(
                      opacity: _isSaving ? 0.7 : 1,
                      duration: const Duration(milliseconds: 250),
                      child: _ProductDetailView(
                        producto: detail.producto,
                        imageUrl: _imageUrl,
                        canApplyDiscount: _maxDiscount > 0,
                        quantityController: _quantityController,
                        discountController: _discountController,
                        notesController: _notesController,
                        onIncreaseQuantity: _increaseQuantity,
                        onDecreaseQuantity: _decreaseQuantity,
                        onQuantityChanged: _onQuantityChanged,
                        onDiscountChanged: _onDiscountChanged,
                        subtotal: _subtotal,
                        discountValue: _discountValue,
                        discountPercent: _discountPercent,
                        total: _total,
                        currencySettings: _currencySettings,
                        isSaving: _isSaving,
                      ),
                    );
                  },
                ),
              ),
              _BottomBar(
                discountValue: _discountValue,
                discountPercent: _discountPercent,
                total: _total,
                currencySettings: _currencySettings,
                isSaving: _isSaving,
                onAddToCart: _addToCart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateDiscountLimits({double? productLimit}) {
    if (!mounted) {
      return;
    }
    final loginState = ref.read(loginControllerProvider);
    final baseProductLimit =
        productLimit ?? (_productMaxDiscount > 0 ? _productMaxDiscount : 0);
    final sanitizedProductLimit =
        baseProductLimit.isFinite ? max(0, baseProductLimit) : 0;
    if (_producto == null && productLimit == null) {
      developer.log('No hay producto cargado para actualizar descuentos',
          name: 'Detalle');
      return;
    }

    final user = loginState.user;
    if (user == null) {
      developer.log('No hay usuario activo al actualizar límites de descuento',
          name: 'Detalle');
    }
    final rawEffectiveMax = user != null
        ? min(sanitizedProductLimit, user.maxDcto)
        : sanitizedProductLimit;
    final effectiveMax = rawEffectiveMax.isFinite
        ? max(0, rawEffectiveMax)
        : 0.0;
    final updatedDiscountPercent = min(_discountPercent, effectiveMax);

    final shouldUpdateState =
        _productMaxDiscount != sanitizedProductLimit ||
        _maxDiscount != effectiveMax ||
        _discountPercent != updatedDiscountPercent;
    if (!shouldUpdateState) {
      return;
    }

    setState(() {
      _productMaxDiscount = sanitizedProductLimit;
      _maxDiscount = effectiveMax;
      _discountPercent = updatedDiscountPercent;
      _discountController.text = _discountPercent.toStringAsFixed(0);
    });
    _recalculateTotals();
  }

  void _handleBack() {
    if (widget.fromBusqueda) {
      showSearch(
        context: context,
        delegate: BuscarProducto(),
        query: widget.busquedaInicial ?? '',
      );
    } else {
      Navigator.pop(context);
    }
  }

  String _formatTime(DateTime time) {
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    final hours = twoDigits(time.hour);
    final minutes = twoDigits(time.minute);
    final seconds = twoDigits(time.second);
    return '$hours:$minutes:$seconds';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Detalle del producto',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({
    required this.producto,
    required this.imageUrl,
    required this.canApplyDiscount,
    required this.quantityController,
    required this.discountController,
    required this.notesController,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onQuantityChanged,
    required this.onDiscountChanged,
    required this.subtotal,
    required this.discountValue,
    required this.discountPercent,
    required this.total,
    required this.currencySettings,
    required this.isSaving,
  });

  final Producto producto;
  final String? imageUrl;
  final bool canApplyDiscount;
  final TextEditingController quantityController;
  final TextEditingController discountController;
  final TextEditingController notesController;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onDiscountChanged;
  final int subtotal;
  final int discountValue;
  final double discountPercent;
  final int total;
  final CurrencyFormatterSettings currencySettings;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(imageUrl: imageUrl, code: producto.codigobarra),
          const SizedBox(height: 24),
          Text(
            producto.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código: ${producto.codigobarra}',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              CurrencyFormatter.format(producto.precio, currencySettings),
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // --- Inicio bloque Descuento ---
          if (canApplyDiscount)
            _DiscountSection(
              controller: discountController,
              onChanged: onDiscountChanged,
              currencySettings: currencySettings,
              unitPrice: producto.precio,
              discountPercent: discountPercent,
            ),
          if (canApplyDiscount) const SizedBox(height: 24),
          // --- Fin bloque Descuento ---
          _QuantitySelector(
            controller: quantityController,
            onIncrease: onIncreaseQuantity,
            onDecrease: onDecreaseQuantity,
            onChanged: onQuantityChanged,
          ),
          const SizedBox(height: 20),
          _NotesField(controller: notesController),
          const SizedBox(height: 24),
          _SummaryCard(
            subtotal: subtotal,
            discountValue: discountValue,
            discountPercent: discountPercent,
            total: total,
            currencySettings: currencySettings,
          ),
          if (isSaving) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.discountValue,
    required this.discountPercent,
    required this.total,
    required this.currencySettings,
    required this.isSaving,
    required this.onAddToCart,
  });

  final int discountValue;
  final double discountPercent;
  final int total;
  final CurrencyFormatterSettings currencySettings;
  final bool isSaving;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalText = CurrencyFormatter.format(total, currencySettings);
    final discountText =
        CurrencyFormatter.format(discountValue, currencySettings);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (discountValue > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '-$discountText (${discountPercent.toStringAsFixed(0)}%)',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4C53A5),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: isSaving ? null : onAddToCart,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🛒', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Añadir',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.code});

  final String? imageUrl;
  final String code;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(28);
    final placeholder = ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        'assets/img/producto.png',
        fit: BoxFit.cover,
      ),
    );

    Widget content;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img/producto.png',
          image: imageUrl!,
          fit: BoxFit.cover,
          imageErrorBuilder: (_, __, ___) =>
              Image.asset('assets/img/producto.png', fit: BoxFit.cover),
        ),
      );
    } else {
      content = placeholder;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Hero(
          tag: 'product-$code',
          child: content,
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.controller,
    required this.onIncrease,
    required this.onDecrease,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _RoundButton(icon: Icons.remove, onPressed: onDecrease),
        const SizedBox(width: 16),
        SizedBox(
          width: 96,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _RoundButton(icon: Icons.add, onPressed: onIncrease),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Icon(icon, color: const Color(0xFF4C53A5)),
        ),
      ),
    );
  }
}

class _DiscountSection extends StatelessWidget {
  const _DiscountSection({
    required this.controller,
    required this.onChanged,
    required this.currencySettings,
    required this.unitPrice,
    required this.discountPercent,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final CurrencyFormatterSettings currencySettings;
  final int unitPrice;
  final double discountPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final originalPriceText =
        CurrencyFormatter.format(unitPrice, currencySettings);
    final discountedValue =
        max(0, (unitPrice * (1 - discountPercent / 100)).round());
    final discountedPriceText =
        CurrencyFormatter.format(discountedValue, currencySettings);
    final isDiscountApplied = discountPercent > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descuento',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            LengthLimitingTextInputFormatter(5),
          ],
          onChanged: onChanged,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.16),
            suffixText: '%',
            suffixStyle: textTheme.titleMedium?.copyWith(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio original: $originalPriceText',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDiscountApplied
                    ? 'Precio con descuento: $discountedPriceText'
                    : 'Precio con descuento: $originalPriceText',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observaciones (opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          minLines: 1,
          maxLength: 50,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            counterStyle:
                theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
            hintText: 'Agregar Observaciones...',
            hintStyle:
                theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.discountValue,
    required this.discountPercent,
    required this.total,
    required this.currencySettings,
  });

  final int subtotal;
  final int discountValue;
  final double discountPercent;
  final int total;
  final CurrencyFormatterSettings currencySettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Subtotal',
            value: CurrencyFormatter.format(subtotal, currencySettings),
          ),
          if (discountValue > 0)
            _SummaryRow(
              label: 'Descuento (${discountPercent.toStringAsFixed(0)}%)',
              value:
                  '-${CurrencyFormatter.format(discountValue, currencySettings)}',
              highlighted: true,
            ),
          const Divider(color: Colors.white24, height: 24),
          _SummaryRow(
            label: 'Total a pagar',
            value: CurrencyFormatter.format(total, currencySettings),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlighted = false,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool highlighted;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = isTotal
        ? theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: highlighted ? const Color(0xFFFFC15E) : Colors.white70,
            fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
          );
    final valueStyle = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
          );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4C53A5),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetail {
  const _ProductDetail({
    required this.producto,
    required this.imageUrl,
    required this.maxDiscount,
  });

  final Producto producto;
  final String imageUrl;
  final double maxDiscount;
}

class LocalRollo {
  const LocalRollo({
    required this.local,
    required this.cajaDoc,
    required this.lineaVenta,
    required this.rutCajero,
    required this.artCantidad,
    required this.artCodigo,
    required this.artDescripcion,
    required this.artDescuento,
    required this.artPrecio,
    required this.totalLinea,
    required this.rutVendedor,
    required this.fechaTransaccion,
    required this.horaTransaccion,
    required this.tipoVenta,
    required this.codImpuesto,
    required this.porceImpuesto,
  });

  final String local;
  final String cajaDoc;
  final double lineaVenta;
  final String rutCajero;
  final double artCantidad;
  final String artCodigo;
  final String artDescripcion;
  final double artDescuento;
  final double artPrecio;
  final double totalLinea;
  final String rutVendedor;
  final String fechaTransaccion;
  final String horaTransaccion;
  final String tipoVenta;
  final String codImpuesto;
  final double porceImpuesto;

  Map<String, Object?> toMap() {
    return {
      'local': local,
      'caja_doc': cajaDoc,
      'linea_venta': lineaVenta,
      'rut_cajero': rutCajero,
      'art_cantidad': artCantidad,
      'art_codigo': artCodigo,
      'art_descripcion': artDescripcion,
      'art_descuento': artDescuento,
      'art_precio': artPrecio,
      'total_linea': totalLinea,
      'rut_vendedor': rutVendedor,
      'fecha_transaccion': fechaTransaccion,
      'hora_transaccion': horaTransaccion,
      'tipoventa': tipoVenta,
      'cod_impuesto': codImpuesto,
      'porce_impuesto': porceImpuesto,
    };
  }
}

class LocalRolloObservaciones {
  const LocalRolloObservaciones({
    required this.codigo,
    required this.fecha,
    required this.caja,
    required this.observaciones,
  });

  final String codigo;
  final String fecha;
  final String caja;
  final String observaciones;

  Map<String, Object?> toMap() {
    return {
      'codigo': codigo,
      'fecha': fecha,
      'caja': caja,
      'observaciones': observaciones,
    };
  }
}

class DBRollo {
  const DBRollo._();

  static const _tableName = 'tbl_rollo_terreno_00';

  static Future<int> getNextLineNumber() async {
    final db = await _open();
    try {
      final result = await db
          .rawQuery('SELECT MAX(linea_venta) as max_line FROM $_tableName');
      var current = 0;
      if (result.isNotEmpty) {
        final value = result.first['max_line'];
        if (value is num) {
          current = value.toInt();
        } else if (value is String) {
          current = int.tryParse(value) ?? 0;
        }
      }
      return current + 1;
    } finally {
      await db.close();
    }
  }

  static Future<void> insert(LocalRollo rollo) async {
    final db = await _open();
    try {
      await db.insert(_tableName, rollo.toMap());
    } finally {
      await db.close();
    }
  }

  static Future<Database> _open() async {
    final path = await _databasePath();
    return openDatabase(path);
  }

  static Future<String> _databasePath() async {
    final databasesPath = await getDatabasesPath();
    return p.join(databasesPath, 'rollo.db');
  }
}

class DBRolloObservaciones {
  const DBRolloObservaciones._();

  static const _tableName = 'local_rollo_observaciones_00';

  static Future<void> insert(LocalRolloObservaciones observacion) async {
    final db = await DBRollo._open();
    try {
      await db.insert(_tableName, observacion.toMap());
    } finally {
      await db.close();
    }
  }
}
