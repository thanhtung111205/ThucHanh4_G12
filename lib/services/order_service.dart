import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderService extends ChangeNotifier {
  static final List<Order> _orders = [];
  static const String _storageKey = 'orders_history';

  static List<Order> get orders => _orders;

  // Load orders from SharedPreferences
  static Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString(_storageKey);
    if (ordersJson != null) {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      _orders.clear();
      _orders.addAll(decoded.map((item) => Order.fromJson(item)).toList());
    }
  }

  // Save orders to SharedPreferences
  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> addOrder(Order order) async {
    _orders.insert(0, order);
    await _saveToPrefs();
  }

  static List<Order> getOrders() {
    return _orders;
  }

  static List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  static Future<void> cancelOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.pending) {
      _orders[index] = Order(
        id: _orders[index].id,
        items: _orders[index].items,
        totalPrice: _orders[index].totalPrice,
        status: OrderStatus.cancelled,
        orderDate: _orders[index].orderDate,
        address: _orders[index].address,
        paymentMethod: _orders[index].paymentMethod,
      );
      await _saveToPrefs();
    }
  }
}
