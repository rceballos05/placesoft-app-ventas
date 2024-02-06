import 'package:app_ventas/pages/producto_detalle_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static String id = 'home_page';

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: bottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            verticalDirection: VerticalDirection.down,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 20, top: 20),
                child: const Text(
                  "Acciones",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              listMenu(),
              Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(left: 20),
                child: const Text(
                  "Productos destacados",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              productos()
            ],
          ),
        ),
      ),
    );
  }
}

Container listMenu() {
  return Container(
    margin: const EdgeInsets.only(left: 35, right: 35, top: 20, bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {},
          child: const Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Buscar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {},
          child: const Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purpleAccent,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Crear Venta",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {},
          child: const Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Ver Perfil",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Container productos() {
  return Container(
    alignment: Alignment.bottomLeft,
    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    height: 350,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, ProductoDetalle.id);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: Card(
                shadowColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: DecoratedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    verticalDirection: VerticalDirection.down,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 90, bottom: 10),
                        child: Text(
                          "prueba",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 100),
                              child: Text(
                                "precio",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    backgroundColor: Colors.transparent),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 15),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  position: DecorationPosition.background,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("https://picsum.photos/275/350"),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
  );
}

BottomNavigationBar bottomNavigation() {
  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: Colors.black,
          ),
          label: ""),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          label: "")
    ],
  );
}
