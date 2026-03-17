import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_item_widget.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<bool> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm?'),
          content: const Text(
            'Bạn có muốn xóa sản phẩm này khỏi giỏ hàng không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          final items = cart.items;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.35),
                  ),
                  const SizedBox(height: 12),
                  const Text('Giỏ hàng đang trống'),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _showDeleteDialog(context),
                      onDismissed: (_) {
                        context.read<CartProvider>().removeItemById(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Đã xóa sản phẩm khỏi giỏ hàng',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      child: CartItemWidget(
                        item: item,
                        onToggleSelected: (value) {
                          context.read<CartProvider>().toggleItemSelection(
                            item.id,
                            value ?? false,
                          );
                        },
                        onIncrease: () {
                          context.read<CartProvider>().increaseQuantity(
                            item.id,
                          );
                        },
                        onDecrease: () async {
                          if (item.quantity > 1) {
                            context.read<CartProvider>().decreaseQuantity(
                              item.id,
                            );
                            return;
                          }
                          final shouldDelete = await _showDeleteDialog(context);
                          if (shouldDelete && context.mounted) {
                            context.read<CartProvider>().removeItemById(
                              item.id,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              _CartBottomBar(
                totalAmount: cart.selectedTotalPrice,
                isAllSelected: cart.isAllSelected,
                selectedCount: cart.selectedItemTypes,
                onToggleSelectAll: (value) {
                  context.read<CartProvider>().toggleSelectAll(value ?? false);
                },
                onCheckout: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.totalAmount,
    required this.isAllSelected,
    required this.selectedCount,
    required this.onToggleSelectAll,
    required this.onCheckout,
  });

  final double totalAmount;
  final bool isAllSelected;
  final int selectedCount;
  final ValueChanged<bool?> onToggleSelectAll;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Checkbox(
            value: isAllSelected,
            onChanged: onToggleSelectAll,
            visualDensity: VisualDensity.compact,
          ),
          const Text('Chọn tất cả'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
                Text(
                  Formatter.formatUsd(totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: selectedCount > 0 ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Mua hàng ($selectedCount)'),
            ),
          ),
        ],
      ),
    );
  }
}
