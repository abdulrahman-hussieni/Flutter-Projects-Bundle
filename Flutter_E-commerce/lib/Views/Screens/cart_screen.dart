import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/CartItem.dart'; // Fixed import path - capital C

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) { // Fixed the typo in build method
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Cart", style: TextStyle(fontWeight: FontWeight.bold,),),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  leading: Image.asset(
                    item.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item.title),
                  subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cartProvider.decreaseQuantity(item.id);
                        },
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          cartProvider.increaseQuantity(item.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Subtotal + taxes
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal:"),
                      Text("\$${cartProvider.subtotal.toStringAsFixed(2)}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Taxes:"),
                      Text("\$${cartProvider.taxes.toStringAsFixed(2)}"),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${cartProvider.total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : () {
                      // TODO: go to checkout page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Proceeding to checkout...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text(
                      "Proceed to Checkout",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}