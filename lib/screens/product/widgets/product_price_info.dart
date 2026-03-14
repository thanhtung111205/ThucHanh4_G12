// screens/product/widgets/product_price_info.dart
//
// Hiển thị khối Tên sản phẩm + Giá:
//   • Tên: in đậm
//   • Giá bán (currentPrice = product.price): to, màu đỏ
//   • Giá gốc (giả định = price * 1.3): xám, gạch ngang
//   • Rating nhỏ bên cạnh

import 'package:flutter/material.dart';

import '../../../models/product.dart';

class ProductPriceInfo extends StatelessWidget {
  const ProductPriceInfo({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Giá gốc giả lập cao hơn 30% (FakeStore không có originalPrice)
    final originalPrice = product.price * 1.30;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tên sản phẩm ──────────────────────────────────────────
          Text(
            product.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // ── Rating nhỏ ──────────────────────────────────────────
          Row(
            children: [
              ...List.generate(5, (i) {
                final fill = i < product.rating.round();
                return Icon(
                  fill ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade600,
                  size: 18,
                );
              }),
              const SizedBox(width: 6),
              Text(
                '${product.rating.toStringAsFixed(1)} (${product.ratingCount} đánh giá)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Khối giá ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Giá bán – to, đỏ
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.redAccent.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              // Giá gốc – xám, gạch ngang
              Text(
                '\$${originalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: theme.colorScheme.onSurface.withOpacity(0.45),
                ),
              ),
              const Spacer(),
              // Chip giảm giá
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade700.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '-23%',
                  style: TextStyle(
                    color: Colors.redAccent.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
