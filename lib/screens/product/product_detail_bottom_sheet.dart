// screens/product/product_detail_bottom_sheet.dart
//
// Modal BottomSheet chọn phân loại sản phẩm.
// Hiển thị khi user bấm "Thêm vào giỏ hàng" hoặc tile "Phân loại".
//
// Chứa:
//   • ChoiceChip Size (S, M, L)
//   • ChoiceChip Màu sắc (với màu nền thực)
//   • Bộ đếm số lượng (−, số, +)
//   • Nút "Xác nhận": đóng sheet + SnackBar + gọi CartProvider.addToCart()

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import 'product_detail_view_model.dart';

// ─── Hàm tiện ích mở BottomSheet ──────────────────────────────────────────────
void showProductBottomSheet(BuildContext context, Product product) {
  // Giữ reference ScaffoldMessenger trước khi mở sheet
  final messenger = ScaffoldMessenger.of(context);
  final cart = context.read<CartProvider>();
  final vm = context.read<ProductDetailViewModel>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,        // Cho phép sheet cao hơn 50% màn hình
    backgroundColor: Colors.transparent,
    builder: (_) {
      // Dùng MultiProvider để sheet truy cập ViewModel và CartProvider
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider.value(value: cart),
        ],
        child: _ProductDetailBottomSheet(
          product: product,
          onConfirm: (size, color, qty) {
            cart.addToCart(product, quantity: qty);
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Thêm thành công!'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    },
  );
}

// ─── Widget nội dung BottomSheet ──────────────────────────────────────────────
class _ProductDetailBottomSheet extends StatefulWidget {
  const _ProductDetailBottomSheet({
    required this.product,
    required this.onConfirm,
  });

  final Product product;
  final void Function(String? size, String? color, int qty) onConfirm;

  @override
  State<_ProductDetailBottomSheet> createState() =>
      _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<_ProductDetailBottomSheet> {
  static const _sizes = ['S', 'M', 'L', 'XL'];
  static const _colors = <String, Color>{
    'Xanh': Color(0xFF1565C0),
    'Đỏ': Color(0xFFB71C1C),
    'Xanh lá': Color(0xFF2E7D32),
    'Đen': Color(0xFF212121),
  };

  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Lấy giá trị đã chọn từ ViewModel (nếu user đã chọn trước đó)
    final vm = context.read<ProductDetailViewModel>();
    _selectedSize = vm.selectedSize;
    _selectedColor = vm.selectedColor;
    _quantity = vm.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ──────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // ── Tiêu đề ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.redAccent.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),

          // ── Chọn kích cỡ ────────────────────────────────────────
          Text('Kích cỡ',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _sizes.map((size) {
              final selected = _selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: selected,
                onSelected: (_) => setState(() => _selectedSize = size),
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(
                  color: selected
                      ? Colors.transparent
                      : theme.colorScheme.outline.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // ── Chọn màu sắc ────────────────────────────────────────
          Text('Màu sắc',
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _colors.entries.map((entry) {
              final isSelected = _selectedColor == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: entry.value.withOpacity(isSelected ? 0.6 : 0.25),
                        blurRadius: isSelected ? 10 : 4,
                        spreadRadius: isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          // Label tên màu đã chọn
          if (_selectedColor != null)
            Text(
              _selectedColor!,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 16),

          // ── Số lượng ────────────────────────────────────────────
          Row(
            children: [
              Text('Số lượng',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              _QuantityButton(
                icon: Icons.remove,
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Nút Xác nhận ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // Cập nhật ViewModel để VariationTile hiển thị đúng
                final vm = context.read<ProductDetailViewModel>();
                if (_selectedSize != null) vm.selectSize(_selectedSize!);
                if (_selectedColor != null) vm.selectColor(_selectedColor!);

                Navigator.pop(context);
                widget.onConfirm(_selectedSize, _selectedColor, _quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget nút Tăng/Giảm số lượng ───────────────────────────────────────────
class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.35),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
