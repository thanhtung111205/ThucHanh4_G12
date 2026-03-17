import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../home/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.selectedItems,
    required this.totalAmount,
    required this.selectedAddress,
    required this.selectedPayment,
  });

  final List<CartItem> selectedItems;
  final double totalAmount;
  final String selectedAddress;
  final String selectedPayment;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Create a new order object
    final newOrder = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(widget.selectedItems),
      totalPrice: widget.totalAmount,
      status: OrderStatus.pending,
      orderDate: DateTime.now(),
      address: widget.selectedAddress,
      paymentMethod: widget.selectedPayment,
    );

    // Save the order to OrderService
    await OrderService.addOrder(newOrder);

    // Remove items from cart
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    for (var item in widget.selectedItems) {
      cartProvider.removeItemById(item.id);
    }

    setState(() {
      _isProcessing = false;
    });

    // Show success dialog
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đơn hàng của bạn đã được đặt',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Clear all dialogs and screens, go back to home
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Tiếp tục mua sắm'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
        leading: _isProcessing
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Items Section
            Text(
              'Danh sách sản phẩm (${widget.selectedItems.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.selectedItems.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final item = widget.selectedItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.variationText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item.product.price.toStringAsFixed(2)}đ x ${item.quantity} = ${item.lineTotal.toStringAsFixed(2)}đ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Address Section
            Text(
              'Địa chỉ giao hàng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.selectedAddress)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method Section
            Text(
              'Phương thức thanh toán',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Text(
                    widget.selectedPayment == 'cod' ? '💰' : '📱',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedPayment == 'cod'
                          ? 'COD (Thanh toán khi nhận)'
                          : 'Momo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Summary Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tóm tắt đơn hàng',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Tổng giá trị:',
                    '${widget.totalAmount.toStringAsFixed(2)}đ',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Phí vận chuyển:', 'Miễn phí'),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Giảm giá:', '0đ'),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Thành tiền:',
                    '${widget.totalAmount.toStringAsFixed(2)}đ',
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Info Section
            if (widget.selectedPayment == 'cod')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bạn sẽ thanh toán tiền mặt khi nhận hàng',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  border: Border.all(color: Colors.purple[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.purple[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sẽ chuyển hướng đến cổng thanh toán Momo',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                icon: _isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isProcessing ? 'Đang xử lý...' : 'Xác nhận thanh toán',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isBold ? Colors.red : Colors.black,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
