import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderService extends ChangeNotifier {
  // Static list to store orders in memory
  static final List<Order> _orders = [];

  static List<Order> get orders => _orders;

  static Future<void> addOrder(Order order) async {
    // Simulate some delay
    await Future.delayed(const Duration(milliseconds: 300));
    _orders.insert(0, order); // Add new order to the top
  }

  static List<Order> getOrders() {
    return _orders;
  }

  static List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // New function to cancel an order
  static void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1 && _orders[index].status == OrderStatus.pending) {
      // Create a new order object with cancelled status
      final cancelledOrder = Order(
        id: _orders[index].id,
        items: _orders[index].items,
        totalPrice: _orders[index].totalPrice,
        status: OrderStatus.cancelled,
        orderDate: _orders[index].orderDate,
        address: _orders[index].address,
        paymentMethod: _orders[index].paymentMethod,
      );
      
      // Update the list
      _orders[index] = cancelledOrder;
    }
  }
}
