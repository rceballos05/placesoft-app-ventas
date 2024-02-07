import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class HomeAppBar extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25),
      child: Row(children: [
        Icon(
          Icons.sort,
          size: 30,
          color: Colors.black,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "Ventas en terreno",
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        Spacer(),
        badges.Badge(
          badgeStyle: badges.BadgeStyle(badgeColor: Colors.red),
          position: badges.BadgePosition.topEnd(top: 0, end: 3),
          badgeContent: Text(
            "3",
            style: TextStyle(color: Colors.white),
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, "cartPage");
            },
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 40,
              color: Colors.black,
            ),
          ),
        )
      ]),
    );
  }
}
