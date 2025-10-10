import 'dart:developer';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:currency_formatter/currency_formatter.dart';

import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/models/rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo.dart';
import 'package:aplicacion_ventas/db/db_rollo_observaciones.dart';
import 'package:aplicacion_ventas/db/rollo.dart';
import 'package:aplicacion_ventas/db/rollo_observaciones.dart';
import 'package:aplicacion_ventas/widgets/busqueda_producto.dart';

class DetallePage extends StatefulWidget {
  const DetallePage({
    super.key,
    this.codigo,
    this.busquedaInicial,
    this.volverABusqueda,
  });

  final String? codigo;
  final String? busquedaInicial;
  final bool? volverABusqueda;

  @override
  State<DetallePage> createState() => _DetallePageState();
}

class _DetallePageState extends State<DetallePage> with SingleTickerProviderStateMixin {
  late Future<dynamic> _data;
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _descuentoController = TextEditingController(text: '0');
  final TextEditingController _observacionesController = TextEditingController();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  Producto? _producto;
  String? _imagenPrincipal;
  int? _stockDisponible;
  int _precioUnitario = 0;
  double _descuentoPercent = 0;
  int total = 0;
  bool _isProcessing = false;
  bool _isButtonPressed = false;

  static const _currencySettings = CurrencyFormatterSettings(
    symbol: '\$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _initDetalle();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cantidadController.dispose();
    _descuentoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _initDetalle() {
    final codigoProducto = (widget.codigo?.isNotEmpty ?? false) ? widget.codigo! : codigo;
    cantidad = 1;
    _cantidadController.text = '1';
    _descuentoController.text = '0';
    _data = obtenerDetalleOffline(codigoProducto);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      totalProducto(1, precio);
    });
  }

  void totalProducto(int? cantidad, int? precio) {
    if (cantidad != null && precio != null) {
      setState(() {
        total = cantidad * precio;
      });
    } else {
      total = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.ensureScreenSize();
    final volverDesdeBusqueda = widget.volverABusqueda ?? fromBusqueda;
    final queryBusqueda = widget.busquedaInicial ?? busqueda;

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            floatingActionButton: _buildFloatingButton(context),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4C53A5), Color(0xFF6A75E1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(context, volverDesdeBusqueda, queryBusqueda),
                    Expanded(
                      child: FutureBuilder<dynamic>(
                        future: _data,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CupertinoActivityIndicator());
                          }
                          if (snapshot.hasError) {
                            final error = snapshot.error;
                            log('Error al obtener detalle del producto: $error');
                            return _ErrorView(
                              mensaje: 'No se pudo cargar el producto seleccionado.',
                              onRetry: _initDetalle,
                            );
                          }
                          if (!snapshot.hasData) {
                            return _ErrorView(
                              mensaje: 'El producto no se encuentra disponible en este momento.',
                              onRetry: _initDetalle,
                            );
                          }

                          final detalle = _parseDetalle(snapshot.data);
                          final producto = detalle.producto;

                          if (_producto?.codigobarra != producto.codigobarra) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              if (_producto?.codigobarra != producto.codigobarra) {
                                _onProductoCargado(detalle);
                              }
                            });
                          }

                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: _DetalleContenido(
                              producto: producto,
                              stockDisponible: _stockDisponible,
                              imagenPrincipal: _imagenPrincipal,
                              cantidadController: _cantidadController,
                              descuentoController: _descuentoController,
                              observacionesController: _observacionesController,
                              descuentoPercent: _descuentoPercent,
                              totalBase: total,
                              descuentoCalculado: _calcularDescuento(total),
                              onIncrementar: () => _actualizarCantidad(cantidad + 1),
                              onDecrementar: () => _actualizarCantidad((cantidad - 1).clamp(1, 999)),
                              onCantidadEditada: _onCantidadEditada,
                              onDescuentoCambiado: _onDescuentoCambiado,
                              vendedorPuedeDescontar: (vendedor.descuento ?? 0) > 0,
                              onLimpiarDescuento: _restablecerDescuento,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: _buildBottomBar(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool volverDesdeBusqueda, String queryBusqueda) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 2,
        vertical: kSpacingUnit.h * 1.6,
      ),
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
              onPressed: () {
                if (volverDesdeBusqueda) {
                  fromDetalle = true;
                  fromBusqueda = false;
                  showSearch(
                    context: context,
                    delegate: BuscarProducto(),
                    query: queryBusqueda,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          SizedBox(width: kSpacingUnit.w * 1.6),
          Expanded(
            child: Text(
              'Detalle del producto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final totalBase = total;
    final descuentoAplicado = _calcularDescuento(totalBase);
    final totalFinal = (totalBase - descuentoAplicado).clamp(0, totalBase);
    final puedeAgregar = !_isProcessing && _producto != null && totalFinal > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 12),
            blurRadius: 24,
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
                  'Total estimado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: Text(
                    CurrencyFormatter.format(totalFinal, _currencySettings),
                    key: ValueKey<int>(totalFinal),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                  ),
                ),
                if (descuentoAplicado > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '- ${CurrencyFormatter.format(descuentoAplicado, _currencySettings)} (${_descuentoPercent.toStringAsFixed(0)}%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          AnimatedScale(
            scale: _isButtonPressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C53A5), Color(0xFF5F68C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C53A5).withOpacity(0.45),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26.r),
                  onTap: puedeAgregar ? _agregarAlCarrito : null,
                  onHighlightChanged: (value) {
                    setState(() {
                      _isButtonPressed = value;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isProcessing)
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Text(
                            '🛒',
                            style: TextStyle(fontSize: 20),
                          ),
                        SizedBox(width: 8.w),
                        Text(
                          'Añadir al carrito',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingButton(BuildContext context) {
    if (_producto == null) {
      return null;
    }
    return FloatingActionButton.extended(
      heroTag: 'volver_catalogo',
      onPressed: () {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      },
      backgroundColor: Colors.white.withOpacity(0.92),
      foregroundColor: const Color(0xFF4C53A5),
      icon: const Icon(CupertinoIcons.square_grid_2x2),
      label: Text(
        'Catálogo',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF4C53A5),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _onProductoCargado(_DetalleProducto detalle) {
    final producto = detalle.producto;
    final stock = detalle.stock ?? _tryGetStock(producto);
    final imagen = detalle.image ?? _resolverImagen(producto.codigobarra);
    final precio = producto.precio;

    setState(() {
      _producto = producto;
      _stockDisponible = stock;
      _imagenPrincipal = imagen;
      _precioUnitario = precio;
      _descuentoPercent = 0;
      _isProcessing = false;
      cantidad = 1;
    });

    _cantidadController.text = '1';
    _descuentoController.text = '0';
    totalProducto(1, precio);
    _fadeController.forward(from: 0);
  }

  void _actualizarCantidad(int nuevaCantidad) {
    final cantidadNormalizada = nuevaCantidad.clamp(1, 999);
    if (cantidadNormalizada == cantidad || _producto == null) {
      return;
    }
    cantidad = cantidadNormalizada;
    _cantidadController.text = cantidadNormalizada.toString();
    totalProducto(cantidadNormalizada, _precioUnitario);
  }

  void _onCantidadEditada(String value) {
    if (value.isEmpty) {
      return;
    }
    final numero = int.tryParse(value);
    if (numero == null || numero <= 0) {
      _cantidadController.text = cantidad.toString();
      return;
    }
    _actualizarCantidad(numero);
  }

  void _onDescuentoCambiado(String value) {
    final maximo = vendedor.descuento?.toDouble() ?? 0;
    if (value.trim().isEmpty) {
      setState(() {
        _descuentoPercent = 0;
      });
      return;
    }
    final nuevoValor = double.tryParse(value) ?? _descuentoPercent;
    if (nuevoValor > maximo) {
      _descuentoController.text = maximo.toStringAsFixed(0);
      _descuentoController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descuentoController.text.length),
      );
      final mensajeError = 'El descuento no puede superar el ${maximo.toStringAsFixed(0)}% permitido.';
      _mostrarAlertaError(context, mensajeError);
      setState(() {
        _descuentoPercent = maximo;
      });
      return;
    }
    setState(() {
      _descuentoPercent = nuevoValor.clamp(0, maximo);
    });
  }

  void _restablecerDescuento() {
    _descuentoController.text = '0';
    setState(() {
      _descuentoPercent = 0;
    });
  }

  int _calcularDescuento(int totalBase) {
    if (totalBase <= 0 || _descuentoPercent <= 0) {
      return 0;
    }
    final descuentoCalculado = (totalBase * (_descuentoPercent / 100)).round();
    return descuentoCalculado.clamp(0, totalBase);
  }

  Future<void> _agregarAlCarrito() async {
    final producto = _producto;
    if (producto == null || _isProcessing) {
      return;
    }

    FocusScope.of(context).unfocus();

    final existe = productos.where((e) => e.artCodigo == producto.codigobarra).isNotEmpty;
    if (existe) {
      mensaje = 'No se puede volver a agregar el mismo producto';
      return _mostrarAlertaError(context, mensaje);
    }

    if (productos.length >= 32) {
      mensaje = 'Se alcanzó el límite de productos permitidos';
      return _mostrarAlertaError(context, mensaje);
    }

    final maximo = vendedor.descuento?.toDouble() ?? 0;
    if (_descuentoPercent > maximo) {
      mensaje = 'El descuento no puede superar el ${maximo.toStringAsFixed(0)}% permitido';
      return _mostrarAlertaError(context, mensaje);
    }

    final totalBase = total;
    final descuentoAplicado = _calcularDescuento(totalBase);
    final totalFinal = (totalBase - descuentoAplicado).clamp(0, totalBase);
    if (totalFinal <= 0) {
      mensaje = 'El total debe ser mayor a cero para agregar el producto';
      return _mostrarAlertaError(context, mensaje);
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final ahora = DateTime.now();
      final fechaIso = ahora.toIso8601String();
      final hora = fechaIso.split('T').last.split('.').first;
      final lineaActual = lineaventa;
      final totalCantidad = cantidad;
      final precioFinalUnitario = totalCantidad > 0 ? (totalFinal / totalCantidad).round() : totalFinal;

      final rollo = Rollo(
        artCantidad: totalCantidad,
        artCodigo: producto.codigobarra,
        artDescripcion: producto.descripcion,
        artDescuento: _descuentoPercent,
        artPrecio: precioFinalUnitario.toDouble(),
        totalLinea: totalFinal.toDouble(),
        tipoventa: 'NPE',
        cajaDoc: vendedor.caja,
        fechaTransaccion: fechaIso,
        local: user?.local ?? '00',
        codImpuesto: '0000',
        porceImpuesto: 0,
        rutCajero: user?.rut ?? vendedor.rut ?? '',
        rutVendedor: vendedor.rut ?? '',
        lineaVenta: lineaActual,
        observacion: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      );

      final tblRollo = LocalRollo(
        local: rollo.local ?? '00',
        cajaDoc: rollo.cajaDoc ?? vendedor.caja ?? '00',
        lineaVenta: (rollo.lineaVenta ?? lineaActual).toDouble(),
        rutCajero: rollo.rutCajero ?? vendedor.rut ?? '',
        artCantidad: (rollo.artCantidad ?? totalCantidad).toDouble(),
        artCodigo: rollo.artCodigo ?? producto.codigobarra,
        artDescripcion: rollo.artDescripcion ?? producto.descripcion,
        artDescuento: rollo.artDescuento ?? 0,
        artPrecio: rollo.artPrecio ?? precioFinalUnitario.toDouble(),
        totalLinea: rollo.totalLinea ?? totalFinal.toDouble(),
        rutVendedor: rollo.rutVendedor ?? vendedor.rut ?? '',
        fechaTransaccion: rollo.fechaTransaccion ?? fechaIso,
        horaTransaccion: hora,
        tipoVenta: rollo.tipoventa ?? 'NPE',
        codImpuesto: rollo.codImpuesto ?? '0000',
        porceImpuesto: rollo.porceImpuesto ?? 0,
      );

      await DBRollo.insert(tblRollo);
      if (_observacionesController.text.trim().isNotEmpty) {
        await DBRolloObservaciones.insert(
          LocalRolloObservaciones(
            codigo: tblRollo.artCodigo,
            fecha: tblRollo.fechaTransaccion,
            caja: tblRollo.cajaDoc,
            observaciones: _observacionesController.text.trim(),
          ),
        );
      }

      productos.add(rollo);
      lineaventa = lineaActual + 1;
      cantidad = 1;
      _cantidadController.text = '1';
      _restablecerDescuento();
      _observacionesController.clear();
      totalProducto(1, _precioUnitario);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('Producto agregado al carrito'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF4C53A5),
            duration: const Duration(seconds: 2),
          ),
        );

      Navigator.pushNamed(context, '/carro');
    } catch (error, stackTrace) {
      log('Error al agregar producto al carrito: $error', stackTrace: stackTrace);
      mensaje = 'No se pudo agregar el producto al carrito. Inténtalo nuevamente.';
      if (mounted) {
        _mostrarAlertaError(context, mensaje);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _mostrarAlertaError(BuildContext context, String text) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  _DetalleProducto _parseDetalle(dynamic raw) {
    if (raw is _DetalleProducto) {
      return raw;
    }
    if (raw is Producto) {
      return _DetalleProducto(
        producto: raw,
        stock: _tryGetStock(raw),
        image: _resolverImagen(raw.codigobarra),
      );
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw as Map);
      Producto? producto;
      int? stock;
      String? imagen;

      final dynamic productoRaw = map['producto'] ?? map['item'] ?? map['data'];
      if (productoRaw is Producto) {
        producto = productoRaw;
        stock = _tryGetStock(productoRaw);
      } else if (productoRaw is Map) {
        producto = _productoFromMap(productoRaw);
        stock = _extraerStockDesdeMap(productoRaw) ?? _extraerStockDesdeMap(map);
      }

      producto ??= _productoFromMap(map);
      stock ??= _extraerStockDesdeMap(map);
      imagen = (map['imagen'] ?? map['image'] ?? map['foto'])?.toString();

      return _DetalleProducto(
        producto: producto,
        stock: stock,
        image: imagen?.isEmpty ?? true ? _resolverImagen(producto.codigobarra) : imagen,
      );
    }

    throw StateError('Formato de detalle no soportado');
  }

  Producto _productoFromMap(Map<dynamic, dynamic> map) {
    String codigoProducto = map['codigobarra']?.toString() ?? map['codigo']?.toString() ?? codigo;
    if (codigoProducto.isEmpty) {
      codigoProducto = codigo;
    }
    final descripcionProducto = map['descripcion']?.toString() ?? map['nombre']?.toString() ?? '';
    final precioProducto = _toInt(map['precio'] ?? map['precioFinal'] ?? map['art_precio']) ?? _precioUnitario;
    final descuentoProducto = _toInt(map['descuento'] ?? map['art_descuento']) ?? 0;

    return Producto(
      codigobarra: codigoProducto,
      descripcion: descripcionProducto,
      precio: precioProducto,
      descuento: descuentoProducto,
    );
  }

  int? _extraerStockDesdeMap(Map<dynamic, dynamic> map) {
    final dynamic valorStock = map['stock'] ?? map['art_stock'] ?? map['disponible'];
    if (valorStock is num) {
      return valorStock.toInt();
    }
    if (valorStock is String) {
      return int.tryParse(valorStock);
    }
    return null;
  }

  int? _tryGetStock(dynamic producto) {
    try {
      final dynamic stock = producto.stock;
      if (stock is num) {
        return stock.toInt();
      }
      if (stock is String) {
        return int.tryParse(stock);
      }
    } catch (_) {
      // Ignorar: algunas implementaciones de Producto no exponen stock.
    }
    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final sanitized = value.replaceAll(RegExp(r'[^0-9-]'), '');
      return int.tryParse(sanitized);
    }
    return null;
  }

  String? _resolverImagen(String? codigoProducto) {
    if (codigoProducto == null || codigoProducto.isEmpty) {
      return null;
    }
    if (url_img == 'null' || url_img.isEmpty) {
      return null;
    }
    return '$url_img$codigoProducto.jpg';
  }
}

class _DetalleProducto {
  const _DetalleProducto({
    required this.producto,
    this.stock,
    this.image,
  });

  final Producto producto;
  final int? stock;
  final String? image;
}

class _DetalleContenido extends StatelessWidget {
  const _DetalleContenido({
    required this.producto,
    required this.stockDisponible,
    required this.imagenPrincipal,
    required this.cantidadController,
    required this.descuentoController,
    required this.observacionesController,
    required this.descuentoPercent,
    required this.totalBase,
    required this.descuentoCalculado,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.onCantidadEditada,
    required this.onDescuentoCambiado,
    required this.vendedorPuedeDescontar,
    required this.onLimpiarDescuento,
  });

  final Producto producto;
  final int? stockDisponible;
  final String? imagenPrincipal;
  final TextEditingController cantidadController;
  final TextEditingController descuentoController;
  final TextEditingController observacionesController;
  final double descuentoPercent;
  final int totalBase;
  final int descuentoCalculado;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;
  final ValueChanged<String> onCantidadEditada;
  final ValueChanged<String> onDescuentoCambiado;
  final bool vendedorPuedeDescontar;
  final VoidCallback onLimpiarDescuento;

  static const _currencySettings = CurrencyFormatterSettings(
    symbol: '\$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalFormateado = CurrencyFormatter.format(totalBase, _currencySettings);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(
                  imagen: imagenPrincipal,
                  codigoProducto: producto.codigobarra,
                ),
                SizedBox(height: 24.h),
                Text(
                  producto.descripcion,
                  style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24.sp,
                      ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        CurrencyFormatter.format(producto.precio, _currencySettings),
                        style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    if (stockDisponible != null)
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_rounded, color: Colors.white70),
                          SizedBox(width: 6.w),
                          Text(
                            'Stock: $stockDisponible',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 24.h),
                _QuantitySelector(
                  controller: cantidadController,
                  onIncrement: onIncrementar,
                  onDecrement: onDecrementar,
                  onChanged: onCantidadEditada,
                ),
                SizedBox(height: 20.h),
                if (vendedorPuedeDescontar)
                  _DiscountField(
                    controller: descuentoController,
                    descuentoPercent: descuentoPercent,
                    onChanged: onDescuentoCambiado,
                    onClear: onLimpiarDescuento,
                  ),
                SizedBox(height: vendedorPuedeDescontar ? 20.h : 0),
                _ObservacionesField(controller: observacionesController),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24.r),
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
                      SizedBox(height: 12.h),
                      _ResumenRow(
                        etiqueta: 'Subtotal',
                        valor: totalFormateado,
                      ),
                      if (descuentoCalculado > 0)
                        _ResumenRow(
                          etiqueta: 'Descuento (${descuentoPercent.toStringAsFixed(0)}%)',
                          valor: '-${CurrencyFormatter.format(descuentoCalculado, _currencySettings)}',
                          destacado: true,
                        ),
                      const Divider(color: Colors.white24, height: 20),
                      _ResumenRow(
                        etiqueta: 'Total a pagar',
                        valor: CurrencyFormatter.format(totalBase - descuentoCalculado, _currencySettings),
                        esTotal: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imagen,
    required this.codigoProducto,
  });

  final String? imagen;
  final String codigoProducto;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(28.r);
    final placeholder = Image.asset(
      'assets/img/producto.png',
      fit: BoxFit.cover,
    );

    Widget contenido;
    if (imagen != null && imagen!.isNotEmpty) {
      contenido = ClipRRect(
        borderRadius: borderRadius,
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/img/producto.png',
          image: imagen!,
          fit: BoxFit.cover,
          imageErrorBuilder: (_, __, ___) => placeholder,
        ),
      );
    } else {
      contenido = ClipRRect(borderRadius: borderRadius, child: placeholder);
    }

    final heroTag = imagen?.isNotEmpty == true
        ? imagen!
        : (codigoProducto.isNotEmpty ? codigoProducto : 'producto-${hashCode}');

    return Hero(
      tag: heroTag,
      child: Container(
        height: 220.h,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: contenido,
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.controller,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );

    return Row(
      children: [
        _RoundButton(
          icon: CupertinoIcons.minus,
          decoration: buttonDecoration,
          onTap: onDecrement,
        ),
        SizedBox(width: 16.w),
        SizedBox(
          width: 90.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        _RoundButton(
          icon: CupertinoIcons.plus,
          decoration: buttonDecoration,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _DiscountField extends StatelessWidget {
  const _DiscountField({
    required this.controller,
    required this.descuentoPercent,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final double descuentoPercent;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descuento autorizado',
          style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            LengthLimitingTextInputFormatter(3),
          ],
          style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '0',
            suffixIcon: IconButton(
              icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.white70),
              onPressed: onClear,
            ),
            suffixText: '%',
            suffixStyle: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Aplicado: ${descuentoPercent.toStringAsFixed(0)}%',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _ObservacionesField extends StatelessWidget {
  const _ObservacionesField({required this.controller});

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
        SizedBox(height: 8.h),
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
            counterStyle: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.14),
            hintText: 'Agregar indicaciones para el despacho…',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          ),
        ),
      ],
    );
  }
}

class _ResumenRow extends StatelessWidget {
  const _ResumenRow({
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
    this.esTotal = false,
  });

  final String etiqueta;
  final String valor;
  final bool destacado;
  final bool esTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estiloEtiqueta = esTotal
        ? theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        : theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: destacado ? FontWeight.w600 : FontWeight.w500,
            );
    final estiloValor = esTotal
        ? theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        : theme.textTheme.titleMedium?.copyWith(
              color: destacado ? const Color(0xFFFFC15E) : Colors.white,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w600,
            );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: estiloEtiqueta,
            ),
          ),
          Text(valor, style: estiloValor),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.decoration,
    required this.onTap,
  });

  final IconData icon;
  final BoxDecoration decoration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: decoration.borderRadius as BorderRadius? ?? BorderRadius.circular(18.r),
      onTap: onTap,
      child: Ink(
        decoration: decoration,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, color: const Color(0xFF4C53A5)),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.mensaje, required this.onRetry});

  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.white70),
            SizedBox(height: 12.h),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 16.h),
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
