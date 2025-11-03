import 'package:aplicacion_ventas/models/clientebusqueda.dart';
import 'package:flutter/material.dart';

class BuscarCliente extends SearchDelegate<ClienteBusquedaDto?> {
  BuscarCliente();

  static Future<List<ClienteBusquedaDto>> Function(String query)? _searcher;

  static void configure({
    required Future<List<ClienteBusquedaDto>> Function(String query) searcher,
  }) {
    _searcher = searcher;
  }

  @override
  String get searchFieldLabel => 'Buscar clientes…';

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
    if (query.trim().isEmpty) {
      return const _SearchHint();
    }
    return _buildBody();
  }

  Widget _buildBody() {
    final searcher = _searcher;
    if (searcher == null) {
      return const _SearchUnavailable();
    }

    return FutureBuilder<List<ClienteBusquedaDto>>(
      future: searcher(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _SearchError(error: snapshot.error.toString());
        }
        final clientes = snapshot.data ?? [];
        if (clientes.isEmpty) {
          return const _EmptyResults();
        }

        return ListView.separated(
          itemCount: clientes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final c = clientes[index];

            final subtitle = [
              if (c.destinoDescripcion != null &&
                  c.destinoDescripcion!.isNotEmpty)
                'Destino: ${c.destinoDescripcion}',
              if (c.direccion.isNotEmpty) c.direccion,
              if (c.comuna.isNotEmpty) c.comuna,
            ].join(' · ');

            return ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(c.nombre),
              subtitle: Text(subtitle),
              onTap: () => close(context, c),
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
        child: Text('Escribe el nombre, RUT o destino del cliente'),
      );
}

class _SearchUnavailable extends StatelessWidget {
  const _SearchUnavailable();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('La búsqueda de clientes no está disponible.'));
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No se encontraron clientes.'));
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Error al buscar clientes: $error'),
            ],
          ),
        ),
      );
}
