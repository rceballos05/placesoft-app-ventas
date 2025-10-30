import 'package:flutter/material.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';

class BuscarProducto extends SearchDelegate<Producto?> {
  static Future<List<Producto>> Function(String query)? _searcher =
      DBProductos.productoSearch;

  static void configure({
    required Future<List<Producto>> Function(String query) searcher,
  }) {
    _searcher = searcher;
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
  Widget buildResults(BuildContext context) => _buildBody();

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) return const _SearchHint();
    return _buildBody();
  }

  Widget _buildBody() {
    final searcher = _searcher;
    if (searcher == null) return const _SearchUnavailable();

    final normalized = query.trim();
    if (normalized.isEmpty) return const _SearchHint();

    return FutureBuilder<List<Producto>>(
      future: searcher(normalized),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _SearchError(error: snapshot.error.toString());
        }
        final productos = snapshot.data ?? const <Producto>[];
        if (productos.isEmpty) return const _EmptyResults();

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: productos.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final producto = productos[index];
            return ListTile(
              title: Text(producto.descripcion),
              subtitle: Text(
                "${producto.codigobarra} · ${producto.codInterno ?? ''}",
              ),
              onTap: () => close(context, producto),
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
  Widget build(BuildContext context) => const Center(
        child: Text('Escribe el nombre o código del producto'),
      );
}

class _SearchUnavailable extends StatelessWidget {
  const _SearchUnavailable();

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('La búsqueda de productos no está disponible.'),
      );
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('No se encontraron productos.'),
      );
}

class _SearchError extends StatelessWidget {
  final String error;
  const _SearchError({required this.error});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Error al buscar productos: $error'),
            ],
          ),
        ),
      );
}
