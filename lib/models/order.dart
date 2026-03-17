import 'package:flutter/material.dart';
import 'cart_item.dart';

enum OrderStatus { pending, shipping, delivered, cancelled }

class Order {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime orderDate;
  final String address;
  final String paymentMethod;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    required this.address,
    required this.paymentMethod,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.shipping:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
