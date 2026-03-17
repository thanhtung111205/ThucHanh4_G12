import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  void _handleUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Order> allOrders = OrderService.getOrders();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: false, // Set to false and use expanded tabs to center
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            labelPadding: EdgeInsets.zero, // Remove default padding
            tabs: [
              _buildTab('Chờ xác nhận', OrderStatus.pending, allOrders),
              _buildTab('Đang giao', OrderStatus.shipping, allOrders),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderListWidget(orders: allOrders, status: OrderStatus.pending, onUpdate: _handleUpdate),
            OrderListWidget(orders: allOrders, status: OrderStatus.shipping, onUpdate: _handleUpdate),
            OrderListWidget(orders: allOrders, status: OrderStatus.delivered, onUpdate: _handleUpdate),
            OrderListWidget(orders: allOrders, status: OrderStatus.cancelled, onUpdate: _handleUpdate),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, OrderStatus status, List<Order> allOrders) {
    final count = allOrders.where((o) => o.status == status).length;
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OrderListWidget extends StatelessWidget {
  final List<Order> orders;
  final OrderStatus status;
  final VoidCallback onUpdate;

  const OrderListWidget({
    super.key,
    required this.orders,
    required this.status,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final filteredOrders = orders.where((o) => o.status == status).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Không có đơn hàng nào', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return OrderItemWidget(order: filteredOrders[index], onUpdate: onUpdate);
      },
    );
  }
}

class OrderItemWidget extends StatelessWidget {
  final Order order;
  final VoidCallback onUpdate;

  const OrderItemWidget({super.key, required this.order, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mã đơn: ${order.id.length > 12 ? order.id.substring(0, 12) + "..." : order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            _buildStatusBadge(),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngày đặt: ${dateFormat.format(order.orderDate)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Tổng tiền: \$${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi tiết sản phẩm:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          item.product.image,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Số lượng: ${item.quantity} · \$${item.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const Divider(height: 24),
                _buildInfoRow(Icons.location_on, 'Địa chỉ nhận hàng:', order.address),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.payment, 'Thanh toán:', order.paymentMethod == 'cod' ? 'Tiền mặt (COD)' : 'Ví điện tử'),
                
                if (order.status == OrderStatus.pending) ...[
                  const Divider(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
          TextButton(
            onPressed: () async {
              await OrderService.cancelOrder(order.id);
              onUpdate();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã hủy đơn hàng thành công')),
              );
            },
            child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: order.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: order.statusColor, width: 0.5),
      ),
      child: Text(
        order.statusText,
        style: TextStyle(
          color: order.statusColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
