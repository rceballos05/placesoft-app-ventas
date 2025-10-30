import 'package:aplicacion_ventas/db/database_helper.dart';
import 'package:aplicacion_ventas/models/cliente.dart';
import 'package:aplicacion_ventas/presentation/widgets/busqueda_cliente.dart';
import 'package:aplicacion_ventas/presentation/widgets/cart_item_tile.dart';
import 'package:aplicacion_ventas/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart page that displays selected products with responsive layout adjustments.
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  static const routeName = '/cart';

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  Cliente? clienteSeleccionado;

  Future<int> _obtenerProximoNumeroVenta() async {
    final db = await DatabaseHelper.openDatabaseFile('ventas.db');
    try {
      final result = await db.rawQuery(
        'SELECT numero_doc FROM local_venta_cabeza_00 '
        'ORDER BY CAST(numero_doc AS INTEGER) DESC LIMIT 1',
      );
      if (result.isNotEmpty) {
        final ultimo = result.first['numero_doc'];
        if (ultimo is int) {
          return ultimo + 1;
        }
        if (ultimo is String) {
          final parsed = int.tryParse(ultimo);
          if (parsed != null) {
            return parsed + 1;
          }
          final match = RegExp(r'\d+').firstMatch(ultimo);
          if (match != null) {
            final value = int.tryParse(match.group(0)!);
            if (value != null) {
              return value + 1;
            }
          }
        }
      }
      return 1;
    } finally {
      await db.close();
    }
  }

  Future<void> _mostrarSelectorCliente(BuildContext context) async {
    final cliente = await showSearch<Cliente?>(
      context: context,
      delegate: BuscarCliente(),
    );
    if (cliente != null) {
      setState(() => clienteSeleccionado = cliente);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente asignado: ${cliente.nombre}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        clienteSeleccionado?.nombre ?? 'Sin cliente asignado',
                      ),
                      subtitle: clienteSeleccionado != null
                          ? Text(clienteSeleccionado!.rut)
                          : const Text('Seleccione un cliente para continuar'),
                      trailing: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _mostrarSelectorCliente(context),
                      ),
                    ),
                  ),
                ),
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
                                if (clienteSeleccionado == null) {
                                  await _mostrarSelectorCliente(context);
                                  if (clienteSeleccionado == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Debe seleccionar un cliente antes de crear la nota.'),
                                      ),
                                    );
                                    return;
                                  }
                                }

                                final messenger =
                                    ScaffoldMessenger.of(context);
                                int numeroVenta;
                                try {
                                  numeroVenta =
                                      await _obtenerProximoNumeroVenta();
                                } catch (error) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'No se pudo obtener el número de nota: $error'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }

                                final wasSaved = await controller
                                    .saveCartToVenta(numeroVenta: numeroVenta);
                                final latestState = ref.read(cartProvider);
                                if (wasSaved) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Nota de pedido #$numeroVenta generada correctamente.',
                                      ),
                                      duration: const Duration(seconds: 2),
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
