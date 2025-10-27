import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import 'product_detail_page.dart';

/// Simple catalogue showcasing a list of demo products.
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  static const routeName = '/products';

  static const CurrencyFormatterSettings _currencySettings =
      CurrencyFormatterSettings(
    symbol: r'$',
    symbolSide: SymbolSide.left,
    thousandSeparator: '.',
    decimalSeparator: ',',
    symbolSeparator: ' ',
  );

  static const List<Product> _products = [
    Product(
      id: '1',
      name: 'Cafetera Automática',
      description:
          'Cafetera de alta presión con programa automático y acabado en acero inoxidable.',
      price: 79990,
      imageUrl:
          'https://images.unsplash.com/photo-1509475826633-fed577a2c71b?auto=format&fit=crop&w=900&q=80',
    ),
    Product(
      id: '2',
      name: 'Audífonos Inalámbricos',
      description:
          'Audífonos Bluetooth con cancelación activa de ruido y 24 horas de batería.',
      price: 119990,
      imageUrl:
          'https://images.unsplash.com/photo-1519677100203-a0e668c92439?auto=format&fit=crop&w=900&q=80',
    ),
    Product(
      id: '3',
      name: 'Smartwatch Deportivo',
      description:
          'Reloj inteligente con GPS integrado, monitoreo de salud y resistencia al agua.',
      price: 99990,
      imageUrl:
          'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?auto=format&fit=crop&w=900&q=80',
    ),
  ];

  String _formatPrice(double value) {
    return CurrencyFormatter.format(
      value,
      currencyFormatterSettings: _currencySettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: _products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: product),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatPrice(product.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
