import 'dart:developer';
import 'dart:io';

import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/cliente_palabra.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:flutter/material.dart';

class BuscarCliente extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar Cliente';
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            Navigator.pushNamed(context, '/perfil');
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.person),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (clienteVenta != null) {
          Navigator.pushNamed(context, '/home');
        } else {
          exit(0);
        }
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Scaffold();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<ClientePalabra> data = [];

    return FutureBuilder(
      future: clienteBusquedaOfline(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error, no se encontraron datos"),
          );
        } else {
          if (snapshot.data != null) {
            data = snapshot.data!;
            log(data.toString());
          }
          return _listClientes(data);
        }
      },
    );
  }

  Widget _listClientes(List<ClientePalabra> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, i) {
        final cliente = data[i];
        return ListTile(
          title: Text(cliente.nombre!),
          subtitle: Text("${cliente.codDestino!}-${cliente.rut!}"),
          onTap: () {
            rutCliente = cliente.rut!;
            codigoDestino = cliente.codDestino!;
            Navigator.pushNamed(context, '/cliente');
          },
        );
      },
    );
  }
}
