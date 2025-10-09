import 'package:aplicacion_ventas/domain/entities/product.dart';

/// Represents a product added to the shopping cart with its quantity.
class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  CartItem copyWith({Product? product, int? quantity}) => CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );

  double get total => product.price * quantity;
}
