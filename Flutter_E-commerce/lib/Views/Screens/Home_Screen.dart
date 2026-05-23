import 'package:flutter/material.dart';

import '../../Models/product_model.dart';
import '../widgets/grid_product_item_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<ProductModel> products = ProductModel.getProducts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // search bar
            _searchBar(),
            const SizedBox(height: 16),
            // filter
            _filterChips(),
            const SizedBox(height: 20),
            // all products
            _productsGrid(),
          ],
        ),
      ),
    );
  }

  // ✅ AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "ShopSmart",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  // ✅ Search Bar
  Widget _searchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ✅ Filter Chips
  Widget _filterChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildChip("All", true),
        const SizedBox(width: 8),
        _buildChip("Featured", false),
        const SizedBox(width: 8),
        _buildChip("New", false),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
    );
  }

  // ✅ Products Grid
  Widget _productsGrid() {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return GridProductItemWidget(item: products[index]);
      },
    );
  }
}
