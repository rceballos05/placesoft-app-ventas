import 'package:flutter/material.dart';

class ItemAppBar extends StatelessWidget {
  const ItemAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(25),
      child: Row(children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.black,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "Productos",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.favorite,
          size: 30,
          color: Colors.red,
        )
      ]),
    );
  }
}
