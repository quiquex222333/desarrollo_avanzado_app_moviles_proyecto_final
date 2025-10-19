import 'package:flutter/material.dart';
import 'presentation/features/products/pages/products_page.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Offline-First',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2C7BE5)),
      home: const ProductsPage(),
    );
  }
}
