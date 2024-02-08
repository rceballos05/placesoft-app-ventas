import 'package:app_ventas/widgets/cart_bottom_navbar.dart';
import 'package:app_ventas/widgets/cart_AppBar.dart';
import 'package:app_ventas/widgets/cart_items.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  static String id = 'cartPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const CartAppBar(),
          Container(
            height: 600,
            padding: const EdgeInsets.only(top: 15),
            decoration: const BoxDecoration(
              color: Color(0xFFEDECF2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(children: [
              const CartItems(),
              Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10),
                // ),
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C53A5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Agregar cupon de descuento",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: const CartBottomNavBar(),
    );
  }
}
