import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/producto_palabra.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:flutter/rendering.dart';

class BuscarProducto extends SearchDelegate {
  final ScrollController _scrollController = ScrollController();

  // Constructor

  @override
  String get searchFieldLabel => 'Buscar Producto';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            indiceAnterior = -1;
            Navigator.pushNamed(context, '/home');
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        indiceAnterior = -1;
        Navigator.pushNamed(context, '/home');
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
    List<ProductoSearch> data = [];

    return FutureBuilder(
      future: productoBusquedaOfline(query),
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
          return _listProductos(context, data);
        }
      },
    );
  }

  Widget _listProductos(BuildContext context, List<ProductoSearch> data) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: data.length,
      itemBuilder: (context, i) {
        if (fromDetalle) {
          fromDetalle = false;
          _scrollToIndex(indiceAnterior);
        }

        return ListTile(
          leading: Image.network(
            '$url_img${data[i].codigo!}.jpg',
            errorBuilder: (context, error, stackTrace) =>
                Image.asset('assets/img/producto.png'),
          ),
          title: Text(data[i].nombre!),
          subtitle: Text(
              "codigo: ${data[i].codigo!}      precio: ${CurrencyFormatter.format(data[i].precio!.toString().split('.')[0], clpSettings)}"),
          onTap: () async {
            busqueda = query;
            indiceAnterior = i;
            precio = data[i].precio!.toInt();
            codigo = data[i].codigo!;
            fromBusqueda = true;
            await Navigator.pushNamed(context, '/detalle');
          },
          selected: i == indiceAnterior,
          selectedColor: Colors.amber,
        );
      },
    );
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * 100.0, // Ajusta la altura del item según tu diseño
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void setState(VoidCallback fn) {
    // Esta función se asegura de que la UI se actualice cuando cambien los estados.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fn();
    });
  }
}
