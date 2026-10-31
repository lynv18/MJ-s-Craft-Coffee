import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  String selectedSize;
  int quantity;
  double unitPrice; // Presyong may size add-on

  CartItem({
    required this.product,
    this.selectedSize = 'Small',
    this.quantity = 1,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;
}

class CartService extends ChangeNotifier {
  static final CartService instance = CartService._internal();
  factory CartService() => instance;
  CartService._internal();

  final List<CartItem> items = [];

  int get totalItems {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  double get grandTotal {
    double total = 0;
    for (var item in items) {
      total += item.totalPrice;
    }
    return total;
  }

  void addToCart(Product product, {String size = 'Small', int qty = 1, double? customPrice}) {
    // Gamitin ang customPrice kung ibinigay, kung hindi ay ang base price ng product
    final priceToAdd = customPrice ?? product.price;

    final index = items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
    );

    if (index >= 0) {
      items[index].quantity += qty;
    } else {
      items.add(
        CartItem(
          product: product,
          selectedSize: size,
          quantity: qty,
          unitPrice: priceToAdd,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(int index) {
    items[index].quantity++;
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (items[index].quantity > 1) {
      items[index].quantity--;
    } else {
      items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    items.clear();
    notifyListeners();
  }
}