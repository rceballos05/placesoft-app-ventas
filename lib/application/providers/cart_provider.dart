import 'package:aplicacion_ventas/domain/entities/cart_item.dart';
import 'package:aplicacion_ventas/domain/entities/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for the shopping cart.
class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  double get total => items.fold(0, (total, item) => total + item.total);

  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);
}

/// Controller that handles cart mutations.
class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  void add(Product product) {
    final index = state.items.indexWhere((item) => item.product.code == product.code);
    if (index >= 0) {
      final updated = [...state.items];
      final current = updated[index];
      updated[index] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(product: product, quantity: 1)]);
    }
  }

  void remove(Product product) {
    final updated = state.items
        .map((item) => item.product.code == product.code
            ? item.copyWith(quantity: item.quantity - 1)
            : item)
        .where((item) => item.quantity > 0)
        .toList();
    state = state.copyWith(items: updated);
  }

  void clear() => state = const CartState();
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);
