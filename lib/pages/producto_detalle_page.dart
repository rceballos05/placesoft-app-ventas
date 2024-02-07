import 'package:app_ventas/widgets/ItemAppBar.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';

class ProductoDetalle extends StatelessWidget {
  const ProductoDetalle({super.key});
  static String id = 'producto_detalle';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDECF2),
      body: ListView(
        children: [
          ItemAppBar(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Image.network(
              "https://picsum.photos/275/350",
              height: 300,
            ),
          ),
          Arc(
            edge: Edge.TOP,
            arcType: ArcType.CONVEY,
            height: 30,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                  top: 50,
                  bottom: 20,
                ),
                child: Row(
                  children: [
                    Text(
                      "Titulo producto",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
