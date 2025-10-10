import 'package:aplicacion_ventas/models/cliente.dart';
import 'package:flutter/material.dart';

class BuscarCliente extends SearchDelegate<Cliente?> {
  BuscarCliente();

  static Future<List<Cliente>> Function(String query)? _searcher;

  static void configure({
    required Future<List<Cliente>> Function(String query) searcher,
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
  Widget buildResults(BuildContext context) {
    return _buildBody();
  }

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

    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const _SearchHint();
    }

    return FutureBuilder<List<Cliente>>(
      future: searcher(normalized),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _SearchError(error: snapshot.error.toString());
        }
        final clientes = snapshot.data ?? const <Cliente>[];
        if (clientes.isEmpty) {
          return const _EmptyResults();
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: clientes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cliente = clientes[index];
            final subtitleParts = [cliente.direccion, cliente.comuna]
                .whereType<String>()
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList();
            return ListTile(
              title: Text(cliente.nombre),
              subtitle: subtitleParts.isEmpty
                  ? null
                  : Text(subtitleParts.join(' · ')),
              onTap: () => close(context, cliente),
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
        'Escribe el nombre o código del cliente',
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
        'La búsqueda de clientes no está disponible.',
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
        'No se encontraron clientes para tu búsqueda.',
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
              'Ocurrió un error al buscar clientes.',
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
