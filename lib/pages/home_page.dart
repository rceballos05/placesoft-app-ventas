import 'package:app_ventas/widgets/categorias_widget.dart';
import 'package:app_ventas/widgets/home_appbar.dart';
import 'package:app_ventas/widgets/productos_widget.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static String id = 'home';
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const HomeAppBar(),
        Container(
          padding: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(
            color: Color(0xFFEDECF2),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    height: 50,
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Buscar",
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.search,
                    size: 27,
                    color: Colors.black,
                  ),
                ]),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                child: const Text(
                  "Categorias",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const CategoriasWidget(),
              Container(
                alignment: Alignment.centerLeft,
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: const Text(
                  "Productos",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const ProductWidget(),
            ],
          ),
        )
      ]),
      bottomNavigationBar: CurvedNavigationBar(
          onTap: (index) {},
          backgroundColor: Colors.transparent,
          height: 60,
          color: const Color(0xFF4C53A5),
          items: const [
            Icon(
              Icons.home,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              CupertinoIcons.cart,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.list,
              size: 30,
              color: Colors.white,
            )
          ]),
    );
  }
}
