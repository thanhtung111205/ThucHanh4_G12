import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late String _selectedAddress;
  late String _selectedPayment;
  late TextEditingController _customAddressController;
  bool _useCustomAddress = true; // Set to true by default to focus on new address entry

  final List<Map<String, String>> _paymentMethods = [
    {'id': 'cod', 'name': 'COD (Thanh toán khi nhận)', 'icon': '💰'},
    {'id': 'momo', 'name': 'Momo', 'icon': '📱'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddress = '';
    _selectedPayment = 'cod';
    _customAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _customAddressController.dispose();
    super.dispose();
  }

  void _navigateToPayment(
    BuildContext context,
    List<CartItem> selectedItems,
    double total,
  ) {
    final finalAddress = _customAddressController.text.trim();
    
    if (finalAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          selectedItems: selectedItems,
          totalAmount: total,
          selectedAddress: finalAddress,
          selectedPayment: _selectedPayment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán'), centerTitle: true),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          final selectedItems = cartProvider.selectedItems;
          final total = cartProvider.selectedTotalPrice;

          if (selectedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có sản phẩm được chọn',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại giỏ hàng'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Items Section
                Text(
                  'Danh sách sản phẩm (${selectedItems.length})',
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
                    itemCount: selectedItems.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      final item = selectedItems[index];
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item.product.price.toStringAsFixed(2)} x ${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '\$${item.lineTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
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
                  'Địa chỉ nhận hàng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Vui lòng nhập địa chỉ nhận hàng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customAddressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Số nhà, tên đường, phường/xã, quận/huyện...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Method Section
                Text(
                  'Chọn phương thức thanh toán',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _paymentMethods.map((method) {
                      final isSelected = method['id'] == _selectedPayment;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPayment = method['id']!;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.05)
                                : Colors.transparent,
                            border: isSelected
                                ? Border(
                                    left: BorderSide(
                                      color: Colors.blue,
                                      width: 4,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: method['id']!,
                                groupValue: _selectedPayment,
                                activeColor: Colors.blue,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedPayment = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                              Text(
                                method['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  method['name']!,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
                      const Text(
                        'Tóm tắt đơn hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Tổng giá trị:',
                        '\$${total.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Phí vận chuyển:', 'Miễn phí'),
                      const Divider(height: 16),
                      _buildSummaryRow(
                        'Thành tiền:',
                        '\$${total.toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _navigateToPayment(context, selectedItems, total);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Đặt Hàng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Back to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại giỏ hàng'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
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
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
