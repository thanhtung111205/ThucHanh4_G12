// screens/product/widgets/product_description.dart
//
// Hiển thị mô tả sản phẩm với tính năng "Xem thêm / Thu gọn".
//   • Mặc định: maxLines = 5
//   • Bấm "Xem thêm" → hiển thị toàn bộ (AnimatedCrossFade)
//   • Trạng thái quản lý qua ProductDetailViewModel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../product_detail_view_model.dart';

class ProductDescription extends StatelessWidget {
  const ProductDescription({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<ProductDetailViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả sản phẩm',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // AnimatedCrossFade giúp chuyển đổi mượt mà
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: vm.isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            // Dạng thu gọn (≤5 dòng)
            firstChild: Text(
              description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                height: 1.6,
              ),
            ),
            // Dạng mở rộng (full text)
            secondChild: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                height: 1.6,
              ),
            ),
          ),

          // Nút Xem thêm / Thu gọn
          GestureDetector(
            onTap: vm.toggleDescription,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                vm.isDescriptionExpanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
