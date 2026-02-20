import 'package:flutter/material.dart';

import 'features/products/presentation/views/product_list_view.dart';

void main() {
  runApp(const TienditaExampleApp());
}

/// Example app demonstrating the Tiendita package
class TienditaExampleApp extends StatelessWidget {
  const TienditaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiendita Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductListView(),
    );
  }
}
