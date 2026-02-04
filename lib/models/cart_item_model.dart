import 'menu_model.dart';

class CartItem {
  final MenuModel menu;
  int quantity;

  CartItem({
    required this.menu,
    this.quantity = 1,
  });

  double get totalPrice => menu.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuId': menu.id,
      'name': menu.name,
      'price': menu.price,
      'imageUrl': menu.imageUrl,
      'quantity': quantity,
    };
  }
}
