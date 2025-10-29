import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/ventas_db.dart';
import 'package:aplicacion_ventas/models/local_venta_cabeza.dart';
import 'package:aplicacion_ventas/models/local_venta_detalle.dart';
import 'package:aplicacion_ventas/models/local_venta_observacion.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Pantalla que muestra el detalle completo de una venta seleccionada.
class DetalleVentaPage extends StatefulWidget {
  const DetalleVentaPage({super.key, required this.venta});

  static const routeName = '/detalle-venta';

  final LocalVentaCabeza venta;

  @override
  State<DetalleVentaPage> createState() => _DetalleVentaPageState();
}

class _DetalleVentaPageState extends State<DetalleVentaPage> {
  static const CurrencyFormatterSettings _currencySettings =
      CurrencyFormatterSettings(
    symbol: r'\$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  late LocalVentaCabeza _venta;
  late Future<List<LocalVentaDetalle>> _detallesFuture;
  late Future<List<LocalVentaObservacion>> _observacionesFuture;
  bool _reenviando = false;
  String? _lastDetalleError;
  String? _lastObservacionError;

  @override
  void initState() {
    super.initState();
    _venta = widget.venta;
    _detallesFuture = _loadDetalles();
    _observacionesFuture = _loadObservaciones();
  }

  Future<List<LocalVentaDetalle>> _loadDetalles() async {
    try {
      return await DBVentaDetalle.getAll(numeroDoc: _venta.numeroDoc);
    } catch (error, stackTrace) {
      debugPrint('Error cargando detalles: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<List<LocalVentaObservacion>> _loadObservaciones() async {
    try {
      return await DBVentaObservaciones.getAll(numeroDoc: _venta.numeroDoc);
    } catch (error, stackTrace) {
      debugPrint('Error cargando observaciones: $error\n$stackTrace');
      rethrow;
    }
  }

  String _formatCurrency(double? value) {
    if (value == null) {
      return '--';
    }
    return CurrencyFormatter.format(value, _currencySettings);
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '--';
    }
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final year = parsed.year.toString().padLeft(4, '0');
      return '$day/$month/$year';
    }
    final parts = value.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return value;
  }

  Future<void> _reenviarPedido() async {
    final numeroDoc = _venta.numeroDoc;
    if (numeroDoc == null || numeroDoc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No es posible enviar un pedido sin número de documento'),
        ),
      );
      return;
    }

    setState(() {
      _reenviando = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      final updatedMap = {
        ..._venta.toMap(),
        'enviado': 1,
        'intentos': _venta.intentos ?? 0,
      };
      final actualizada = LocalVentaCabeza.fromMap(updatedMap);
      await DBVentaCabeza.update(actualizada);
      if (!mounted) {
        return;
      }
      setState(() {
        _venta = actualizada;
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Pedido enviado correctamente')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text('Error al enviar el pedido: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _reenviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = (_venta.enviado ?? 0) == 1 ? Colors.green : Colors.red;
    final statusText = (_venta.enviado ?? 0) == 1
        ? '✅ Pedido Enviado al Servidor'
        : '🔴 Pedido pendiente de envío';

    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pedido #${_venta.numeroDoc ?? '--'}'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final detallesFuture = _loadDetalles();
            final observacionesFuture = _loadObservaciones();
            setState(() {
              _detallesFuture = detallesFuture;
              _observacionesFuture = observacionesFuture;
              _lastDetalleError = null;
              _lastObservacionError = null;
            });
            await Future.wait([detallesFuture, observacionesFuture]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _venta.nombreCliente?.isNotEmpty == true
                              ? _venta.nombreCliente!
                              : 'Cliente sin nombre',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'Rut cliente',
                          value: _venta.rutCliente ?? '--',
                        ),
                        _InfoRow(
                          label: 'Vendedor',
                          value: _venta.rutVendedor ?? '--',
                        ),
                        _InfoRow(
                          label: 'Fecha emisión',
                          value: _formatDate(_venta.fechaEmision),
                        ),
                        _InfoRow(
                          label: 'Monto total',
                          value: _formatCurrency(_venta.montoTotal),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if ((_venta.observacion ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Observación de cabecera',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(_venta.observacion!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ítems del pedido',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<LocalVentaDetalle>>(
                  future: _detallesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      final message = 'Error al cargar los ítems: ${snapshot.error}';
                      if (_lastDetalleError != message) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                        });
                        _lastDetalleError = message;
                      }
                      return _SectionError(onRetry: () {
                        setState(() {
                          _detallesFuture = _loadDetalles();
                          _lastDetalleError = null;
                        });
                      });
                    }

                    final detalles = snapshot.data ?? [];
                    if (detalles.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No hay ítems registrados.'),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: detalles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final detalle = detalles[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detalle.artDescripcion?.isNotEmpty == true
                                      ? detalle.artDescripcion!
                                      : 'Artículo sin descripción',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text('Código: ${detalle.artCodigo ?? '--'}'),
                                Text('Cantidad: ${detalle.artCantidad ?? 0}'),
                                Text('Precio unitario: ${_formatCurrency(detalle.artPrecio)}'),
                                Text('Total línea: ${_formatCurrency(detalle.totalLinea)}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Observaciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<LocalVentaObservacion>>(
                  future: _observacionesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      final message =
                          'Error al cargar las observaciones: ${snapshot.error}';
                      if (_lastObservacionError != message) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                        });
                        _lastObservacionError = message;
                      }
                      return _SectionError(onRetry: () {
                        setState(() {
                          _observacionesFuture = _loadObservaciones();
                          _lastObservacionError = null;
                        });
                      });
                    }

                    final observaciones = snapshot.data ?? [];
                    if (observaciones.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Sin observaciones adicionales.'),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: observaciones.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final observacion = observaciones[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              observacion.observaciones?.isNotEmpty == true
                                  ? observacion.observaciones!
                                  : 'Observación sin contenido',
                            ),
                            subtitle: Text(
                              'Línea: ${observacion.lineaVenta ?? '--'}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                if ((_venta.enviado ?? 0) == 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reenviando ? null : _reenviarPedido,
                      icon: _reenviando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        _reenviando ? 'Enviando...' : 'Enviar Pedido',
                      ),
                    ),
                  )
                else
                  Text(
                    '✅ Pedido Enviado al Servidor',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.green),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('No se pudo cargar la información.'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
