import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  void addItem(String id, String title, String imageUrl, double price) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
    } else {
      _items[id] = CartItem(
        id: id,
        title: title,
        imageUrl: imageUrl,
        price: price,
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity--;
      } else {
        _items.remove(id);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String id) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity++;
      notifyListeners();
    }
  }

  double get subtotal {
    double sum = 0.0;
    _items.forEach((key, item) {
      sum += item.price * item.quantity;
    });
    return sum;
  }

  double get taxes => subtotal * 0.1;

  double get total => subtotal + taxes;

  int get itemCount {
    int count = 0;
    _items.forEach((key, item) {
      count += item.quantity;
    });
    return count;
  }
}