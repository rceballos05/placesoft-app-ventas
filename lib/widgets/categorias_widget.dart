import 'package:app_ventas/functions/productos_fn.dart';
import 'package:flutter/material.dart';

class CategoriasWidget extends StatelessWidget {
  const CategoriasWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: obtenerCategorias(),
        builder: (BuildContext context, snapshot) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              // ignore: unused_local_variable
              for (var item in snapshot.data)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () {
                      print(item.codigo);
                    },
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://picsum.photos/275/350",
                            width: 40,
                            height: 40,
                          ),
                          Text(
                            item.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ]),
                  ),
                )
            ]),
          );
        });
  }
}
