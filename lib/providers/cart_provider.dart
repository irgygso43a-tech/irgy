import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/menu_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addItem(MenuModel menu) {
    int index = _items.indexWhere((item) => item.menu.id == menu.id);
    
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(menu: menu, quantity: 1));
    }
    
    notifyListeners();
  }

  void removeItem(String menuId) {
    _items.removeWhere((item) => item.menu.id == menuId);
    notifyListeners();
  }

  void increaseQuantity(String menuId) {
    int index = _items.indexWhere((item) => item.menu.id == menuId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String menuId) {
    int index = _items.indexWhere((item) => item.menu.id == menuId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String menuId) {
    return _items.any((item) => item.menu.id == menuId);
  }

  int getQuantity(String menuId) {
    int index = _items.indexWhere((item) => item.menu.id == menuId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
