import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/presentation/pages/detalle.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';

/// Search delegate used to query local products without blocking the UI.
class BuscarProducto extends SearchDelegate<Producto?> {
  BuscarProducto();

  static Future<List<Producto>> Function(String query)? _searcher;
  static CurrencyFormatterSettings _currencySettings =
      const CurrencyFormatterSettings(
    symbol: r'\$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  /// Configures the delegate with a search function and optional formatter.
  static void configure({
    required Future<List<Producto>> Function(String query) searcher,
    CurrencyFormatterSettings? currencySettings,
  }) {
    _searcher = searcher;
    if (currencySettings != null) {
      _currencySettings = currencySettings;
    }
  }

  @override
  String get searchFieldLabel => 'Buscar productos…';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsOrSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const _SearchHint();
    }
    return _buildResultsOrSuggestions();
  }

  Widget _buildResultsOrSuggestions() {
    final searcher = _searcher;
    if (searcher == null) {
      return const _SearchUnavailable();
    }

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const _SearchHint();
    }

    return FutureBuilder<List<Producto>>(
      future: searcher(trimmedQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _SearchError(error: snapshot.error.toString());
        }
        final results = snapshot.data ?? const <Producto>[];
        if (results.isEmpty) {
          return const _EmptyResults();
        }
        return ListView.separated(
          itemCount: results.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final producto = results[index];
            final price =
                CurrencyFormatter.format(producto.precio, _currencySettings);
            return ListTile(
              title: Text(
                producto.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(price),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Detalle(
                      codigo: producto.codigobarra, // ← aquí le pasas el código
                      busquedaInicial: producto.descripcion, // opcional
                      fromBusqueda: true, // o true según el caso
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Ingresa al menos un término para buscar',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SearchUnavailable extends StatelessWidget {
  const _SearchUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'La búsqueda no está disponible en este momento.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No se encontraron productos para tu búsqueda.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              'Ocurrió un error al buscar productos.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
