import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/ventas_db.dart';
import 'package:aplicacion_ventas/models/local_venta_cabeza.dart';
import 'package:aplicacion_ventas/presentation/pages/detalle_venta_page.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Historial de ventas con filtros y navegación al detalle del pedido.
class HistorialPage extends ConsumerStatefulWidget {
  const HistorialPage({super.key});

  static const routeName = '/historial';

  @override
  ConsumerState<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends ConsumerState<HistorialPage> {
  static const CurrencyFormatterSettings _currencySettings =
      CurrencyFormatterSettings(
    symbol: r'\$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  DateTime? _selectedDate;
  late Future<List<LocalVentaCabeza>> _ventasFuture;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    _ventasFuture = _loadVentas();
  }

  Future<List<LocalVentaCabeza>> _loadVentas({DateTime? fecha}) async {
    try {
      final ventas = await DBVentaCabeza.getAll();
      final sortedVentas = List<LocalVentaCabeza>.from(ventas)
        ..sort((a, b) {
          final dateA = _parseDate(a.fechaEmision);
          final dateB = _parseDate(b.fechaEmision);
          if (dateA == null && dateB == null) {
            return 0;
          }
          if (dateA == null) {
            return 1;
          }
          if (dateB == null) {
            return -1;
          }
          return dateB.compareTo(dateA);
        });

      if (fecha == null) {
        return sortedVentas;
      }

      final filterKey = _formatKey(fecha);
      return sortedVentas
          .where((venta) {
            final raw = venta.fechaEmision;
            if (raw == null || raw.isEmpty) {
              return false;
            }
            final parsed = _parseDate(raw);
            if (parsed != null) {
              return _formatKey(parsed) == filterKey;
            }
            return raw.startsWith(filterKey);
          })
          .toList();
    } catch (error, stackTrace) {
      debugPrint('Error cargando ventas: $error\n$stackTrace');
      rethrow;
    }
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
    final parts = value.split(' ');
    if (parts.isEmpty) {
      return null;
    }
    final dateParts = parts.first.split('-');
    if (dateParts.length != 3) {
      return null;
    }
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  String _formatKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDisplayDate(String? value) {
    final date = _parseDate(value);
    if (date != null) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString().padLeft(4, '0');
      return '$day/$month/$year';
    }
    if (value == null || value.isEmpty) {
      return '--';
    }
    final parts = value.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return value;
  }

  String _formatCurrency(double? value) {
    if (value == null) {
      return '--';
    }
    return CurrencyFormatter.format(value, _currencySettings);
  }

  Future<void> _filtrarPorFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final future = _loadVentas(fecha: picked);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedDate = picked;
        _ventasFuture = future;
        _lastErrorMessage = null;
      });
    }
  }

  Future<void> _clearFilter() async {
    final future = _loadVentas();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedDate = null;
      _ventasFuture = future;
      _lastErrorMessage = null;
    });
  }

  Future<void> _refreshVentas() async {
    final future = _loadVentas(fecha: _selectedDate);
    if (!mounted) {
      return;
    }
    setState(() {
      _ventasFuture = future;
      _lastErrorMessage = null;
    });
    await future;
  }

  Future<void> _abrirDetalle(LocalVentaCabeza venta) async {
    await Navigator.pushNamed(
      context,
      DetalleVentaPage.routeName,
      arguments: venta,
    );
    if (!mounted) {
      return;
    }
    await _refreshVentas();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de ventas'),
          actions: [
            if (_selectedDate != null)
              IconButton(
                tooltip: 'Limpiar filtro',
                onPressed: _clearFilter,
                icon: const Icon(Icons.filter_alt_off),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _filtrarPorFecha,
          tooltip: 'Filtrar por fecha',
          child: const Icon(Icons.filter_alt),
        ),
        body: FutureBuilder<List<LocalVentaCabeza>>(
          future: _ventasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final message = 'Error al cargar las ventas: ${snapshot.error}';
              if (_lastErrorMessage != message) {
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
                _lastErrorMessage = message;
              }

              return _ErrorView(
                message: message,
                onRetry: _refreshVentas,
              );
            }

            final ventas = snapshot.data ?? [];
            if (ventas.isEmpty) {
              return _EmptyView(
                hasFilter: _selectedDate != null,
                onClearFilter: _selectedDate != null ? _clearFilter : null,
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshVentas,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: ventas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final venta = ventas[index];
                  final enviado = venta.enviado == 1;
                  final statusColor = enviado ? Colors.green : Colors.red;
                  final statusText = enviado ? 'Enviado' : 'Pendiente';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(
                          enviado ? Icons.check_circle : Icons.cloud_off,
                          color: statusColor,
                        ),
                      ),
                      title: Text(
                        venta.nombreCliente?.isNotEmpty == true
                            ? venta.nombreCliente!
                            : 'Cliente sin nombre',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Documento: ${venta.numeroDoc ?? '--'}'),
                            Text('Fecha: ${_formatDisplayDate(venta.fechaEmision)}'),
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(venta.montoTotal),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
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
                        ],
                      ),
                      onTap: () => _abrirDetalle(venta),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasFilter, this.onClearFilter});

  final bool hasFilter;
  final Future<void> Function()? onClearFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasFilter
                  ? 'No se encontraron ventas para la fecha seleccionada.'
                  : 'No hay ventas registradas.',
              textAlign: TextAlign.center,
            ),
            if (hasFilter && onClearFilter != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Quitar filtro'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
