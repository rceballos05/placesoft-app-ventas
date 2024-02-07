import 'package:app_ventas/widgets/categoriasWidget.dart';
import 'package:app_ventas/widgets/homeAppBar.dart';
import 'package:app_ventas/widgets/productosWidget.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatelessWidget {
  static String id = 'home';
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        HomeAppBar(),
        Container(
          padding: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: Color(0xFFEDECF2),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)),
                child: Row(children: [
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    height: 50,
                    width: 300,
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Buscar",
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.search,
                    size: 27,
                    color: Colors.black,
                  ),
                ]),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                child: Text(
                  "Categorias",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              CategoriasWidget(),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Text(
                  "Productos",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ProductWidget(),
            ],
          ),
        )
      ]),
      bottomNavigationBar: CurvedNavigationBar(
          onTap: (index) {},
          backgroundColor: Colors.transparent,
          height: 70,
          color: Color(0xFF4C53A5),
          items: [
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
