import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isCreatingOrder = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isCreatingOrder => _isCreatingOrder;

  Future<void> loadOrders() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading orders: $e');
    }
  }

  Future<bool> createOrder(List<CartItem> cartItems, String? paymentMethod) async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    _isCreatingOrder = true;
    notifyListeners();

    try {
      List<OrderItem> orderItems = cartItems.map((cartItem) {
        return OrderItem(
          menuId: cartItem.menu.id,
          name: cartItem.menu.name,
          price: cartItem.menu.price,
          imageUrl: cartItem.menu.imageUrl,
          quantity: cartItem.quantity,
        );
      }).toList();

      double totalPrice = cartItems.fold(0, (sum, item) => sum + item.totalPrice);

      OrderModel order = OrderModel(
        id: '',
        userId: user.uid,
        items: orderItems,
        totalPrice: totalPrice,
        status: 'pending',
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('orders').add(order.toMap());

      _isCreatingOrder = false;
      notifyListeners();
      
      // Reload orders
      await loadOrders();
      
      return true;
    } catch (e) {
      _isCreatingOrder = false;
      notifyListeners();
      print('Error creating order: $e');
      return false;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });
      
      await loadOrders();
    } catch (e) {
      print('Error cancelling order: $e');
    }
  }
}
