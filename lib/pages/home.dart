import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:aplicacion_ventas/db/db_precios.dart';
import 'package:aplicacion_ventas/db/db_productos.dart';
import 'package:aplicacion_ventas/db/precios.dart';
import 'package:aplicacion_ventas/db/productos.dart';
import 'package:aplicacion_ventas/functions/functions.dart';
import 'package:aplicacion_ventas/models/producto.dart';
import 'package:aplicacion_ventas/widgets/busqueda_cliente.dart';
import 'package:aplicacion_ventas/statics/globals.dart';
import 'package:aplicacion_ventas/statics/statics.dart';
import 'package:aplicacion_ventas/widgets/busqueda_producto.dart';
import 'package:currency_formatter/currency_formatter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;

final TextEditingController _search = TextEditingController();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ValueNotifier<int> _cantidadCarro = ValueNotifier(0);
  List<Producto> pr = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      obtenerProductosOfline();
      _cantidadCarro.value = productos.length;
      actualizarRollo();
    });

    if (sincroniza && conexionInternet) {
      enviarVentasServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _cantidadCarro.value = productos.length;
    });
    var search = SizedBox(
      height: kSpacingUnit.h * 5,
      width: kSpacingUnit.w * 30,
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: kSpacingUnit * 5,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  height: kSpacingUnit.h * 5,
                  width: kSpacingUnit.w * 17,
                  child: TextFormField(
                    controller: _search,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Buscar',
                        hintStyle: TextStyle(color: Colors.white70)),
                    style: kSearchBoxTextStyle,
                  ),
                ),
                const SizedBox(
                  width: 18,
                ),
                InkWell(
                  child: const Icon(
                    LineAwesomeIcons.search,
                    color: kAccentColor,
                    size: 25,
                  ),
                  onTap: () {
                    showSearch(
                        query: _search.text,
                        context: context,
                        delegate: BuscarProducto());
                  },
                )
              ],
            ),
          )
        ],
      ),
    );

    var searchMinPantalla = SizedBox(
      height: kSpacingUnit.h * 5,
      width: kSpacingUnit.w * 30,
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            height: kSpacingUnit * 5,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  height: kSpacingUnit.h * 5,
                  width: kSpacingUnit.w * 17,
                  child: TextFormField(
                    controller: _search,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Buscar',
                        hintStyle: TextStyle(color: Colors.white70)),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 18,
                ),
                InkWell(
                  child: const Icon(
                    LineAwesomeIcons.search,
                    color: kAccentColor,
                    size: 25,
                  ),
                  onTap: () {
                    showSearch(
                        query: _search.text,
                        context: context,
                        delegate: BuscarProducto());
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 2),
        InkWell(
          child: Icon(
            LineAwesomeIcons.user,
            size: ScreenUtil().setSp(kSpacingUnit.w * 3),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/perfil');
          },
        ),
        const Spacer(),
        const Center(
          child: Text(
            "Ventas en Terreno",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
        const Spacer(),
        ValueListenableBuilder<int>(
          valueListenable: _cantidadCarro,
          builder: (context, value, child) {
            return badges.Badge(
              badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: Text(
                value.toString(),
                style: kCaptionTextStyle,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/carro');
                },
                child: Icon(
                  LineAwesomeIcons.shopping_cart,
                  size: ScreenUtil().setSp(kSpacingUnit.w * 4),
                ),
              ),
            );
          },
        ),
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    var headerMin = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 2),
        InkWell(
          child: Icon(
            LineAwesomeIcons.user,
            size: ScreenUtil().setSp(kSpacingUnit.w * 6),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/perfil');
          },
        ),
        const Spacer(),
        const Center(
          child: Text(
            "Ventas en Terreno",
            style: TextStyle(color: Colors.white, fontSize: 19),
          ),
        ),
        const Spacer(),
        ValueListenableBuilder<int>(
          valueListenable: _cantidadCarro,
          builder: (context, value, child) {
            return badges.Badge(
              badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: Text(
                value.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/carro');
                },
                child: Icon(
                  LineAwesomeIcons.shopping_cart,
                  size: ScreenUtil().setSp(kSpacingUnit.w * 6),
                ),
              ),
            );
          },
        ),
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );
    dynamic productosList;

    productosList = Expanded(
      // Cambiado a Expanded
      child: GridView.count(
        childAspectRatio: 0.68,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: [
          for (var item in pr)
            InkWell(
              onTap: () {
                codigo = item.codigobarra!;
                precio = item.precio!;
                Navigator.pushNamed(context, '/detalle');
              },
              child: Container(
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
                      if (item.descuento! > 0)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.descuento.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    height: 100,
                    width: 100,
                    child: Image.network(
                      '$url_img${item.codigobarra}.jpg',
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/img/producto.png'),
                      height: 300,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.descripcion!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kSpacingUnit.h * 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(item.precio, clpSettings),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
        ],
      ),
    );

    dynamic productosListMin;

    productosListMin = Expanded(
      child: GridView.count(
        childAspectRatio: 0.80,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: [
          for (var item in pr)
            InkWell(
              onTap: () {
                codigo = item.codigobarra!;
                precio = item.precio!;
                Navigator.pushNamed(context, '/detalle');
              },
              child: Container(
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
                      if (item.descuento! > 0)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.descuento.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    height: 80,
                    width: 80,
                    child: Image.network(
                      '$url_img${item.codigobarra}.jpg',
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/img/producto.png'),
                      height: 300,
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.descripcion!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kSpacingUnit.h * 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyFormatter.format(
                              item.precio ?? 0, clpSettings),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
        ],
      ),
    );

    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: <Widget>[
                      SizedBox(height: kSpacingUnit.w * 5),
                      headerMin,
                      SizedBox(height: kSpacingUnit.w * 1),
                      searchMinPantalla,
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: const Center(
                          child: Text(
                            "Productos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.59,
                          child: productosListMin,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      SizedBox(height: kSpacingUnit.w * 5),
                      header,
                      SizedBox(height: kSpacingUnit.w * 1),
                      search,
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: const Center(
                          child: Text(
                            "Productos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: productosList,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            bottomNavigationBar: CurvedNavigationBar(
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/carro');
                } else if (index == 2) {
                  showSearch(context: context, delegate: BuscarCliente());
                }
              },
              backgroundColor: Colors.transparent,
              height: 60,
              color: const Color(0xFF4C53A5),
              items: const [
                Icon(
                  LineAwesomeIcons.home,
                  size: 30,
                  color: Colors.white,
                ),
                Icon(
                  LineAwesomeIcons.shopping_bag,
                  size: 30,
                  color: Colors.white,
                ),
                Icon(
                  Icons.person_search,
                  size: 30,
                  color: Colors.white,
                )
              ],
            ),
            resizeToAvoidBottomInset: false,
          );
        },
      ),
    );
  }

  void obtenerProductosOfline() async {
    var result = await DBProductos.productos();
    for (MaeArticulos item in result) {
      pr.add(Producto(
        codigobarra: item.codigobarra,
        codDepto: item.codDepto,
        codLinea: item.codLinea,
        codMarca: item.codMarca,
        codSeccion: item.codSeccion,
        contenido: item.contenido,
        descripcion: item.descripcion,
        descuento: item.descuento.toInt(),
        precio: 0,
        precioCostoCiva: item.precioCostoCiva.round().toInt(),
      ));
    }
    for (var p in pr) {
      MaeArticulosPrecios result = await DBPrecios.get(p.codigobarra!);
      p.precio = result.precioVenta.toInt();
      p.stock = 0;
    }
    setState(() {});
  }

  void actualizarRollo() async {
    await obtenerRolloYActualizarOffline();
    setState(() {});
  }

  void _mostrarProgressBar(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Enviando Data'),
        content: Flexible(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
