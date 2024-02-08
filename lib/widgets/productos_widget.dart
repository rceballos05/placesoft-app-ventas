import 'package:app_ventas/pages/producto_detalle_page.dart';
import 'package:flutter/material.dart';

class ProductWidget extends StatelessWidget {
  const ProductWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 0.68,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "-50%",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                ),
              ],
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, ProductoDetalle.id);
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 120,
                width: 120,
                child: Image.network("https://picsum.photos/275/350"),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Titulo producto 1",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Descripcion producto 1",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$1500",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.black,
                  )
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }
}
