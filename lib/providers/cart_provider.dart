import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/destination_dao.dart';

class CartItem {
  final DestinationDAO destination;
  int travelers;
  CartItem(this.destination, this.travelers);
  double get subtotal => destination.price * travelers;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.values.fold(0, (a, b) => a + b.travelers);
  bool get isEmpty => _items.isEmpty;
  double get subtotal => _items.values.fold(0.0, (a, b) => a + b.subtotal);

  double discountAmount(int percent) => subtotal * percent / 100;
  double totalWith(int percent) => subtotal - discountAmount(percent);

  void add(DestinationDAO d) {
    final existing = _items[d.id];
    if (existing != null) {
      existing.travelers++;
    } else {
      _items[d.id] = CartItem(d, 1);
    }
    notifyListeners();
  }

  void setTravelers(String id, int n) {
    if (n <= 0) {
      _items.remove(id);
    } else {
      _items[id]?.travelers = n.clamp(1, 20);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
