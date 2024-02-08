import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CategoriasWidget extends StatelessWidget {
  const CategoriasWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (int i = 1; i < 8; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Image.network(
                "https://picsum.photos/275/350",
                width: 40,
                height: 40,
              ),
              const Text(
                "categoria 1",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}
