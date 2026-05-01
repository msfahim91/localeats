import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({required this.id, required this.name, required this.price, required this.image, this.quantity = 1});
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  String _vendorId = '';
  String _vendorName = '';
  String _promoCode = '';
  double _discount = 0;

  List<CartItem> get items => _items;
  String get vendorId => _vendorId;
  String get vendorName => _vendorName;
  String get promoCode => _promoCode;
  double get discountPercent => _discount * 100;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get deliveryFee => subtotal > 0 ? 40 : 0;
  double get discountAmount => subtotal * _discount;
  double get total => subtotal + deliveryFee - discountAmount;

  void addItem(CartItem item, String vendorId, String vendorName) {
    if (_vendorId != vendorId && _items.isNotEmpty && vendorId.isNotEmpty) {
      _items.clear();
    }
    if (vendorId.isNotEmpty) { _vendorId = vendorId; _vendorName = vendorName; }
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(id: item.id, name: item.name, price: item.price, image: item.image));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) { _items[index].quantity--; } else { _items.removeAt(index); }
    }
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    if (code.toUpperCase() == 'LOCALEATS10') {
      _promoCode = code; _discount = 0.10; notifyListeners(); return true;
    }
    return false;
  }

  void clearCart() {
    _items.clear(); _vendorId = ''; _vendorName = ''; _promoCode = ''; _discount = 0;
    notifyListeners();
  }
}
