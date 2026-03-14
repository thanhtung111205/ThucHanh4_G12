// screens/product/widgets/product_image_slider.dart
//
// Hiển thị slider ảnh ngang với:
//   • Hero animation trên ảnh đầu tiên (chuyển cảnh mượt từ Home)
//   • PageView cho phép vuốt ngang
//   • Dot indicator cập nhật realtime qua ViewModel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product.dart';
import '../product_detail_view_model.dart';

class ProductImageSlider extends StatefulWidget {
  const ProductImageSlider({super.key, required this.product});

  final Product product;

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  late final PageController _pageController;

  // FakeStore API chỉ có 1 ảnh; ta tạo list giả lập đa góc độ bằng cách
  // lặp lại ảnh gốc để demo slider hoạt động đúng như yêu cầu.
  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _images = [
      widget.product.image,
      widget.product.image,
      widget.product.image,
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductDetailViewModel>();
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: vm.updateImageIndex,
            itemBuilder: (context, index) {
              final imageWidget = Container(
                color: theme.colorScheme.surfaceVariant,
                padding: const EdgeInsets.all(24),
                child: Image.network(
                  _images[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported, size: 64),
                  ),
                ),
              );

              // Hero chỉ bao bọc ảnh đầu tiên để khớp với tag trên ProductCard
              if (index == 0) {
                return Hero(
                  tag: 'product-image-${widget.product.id}',
                  child: imageWidget,
                );
              }
              return imageWidget;
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (index) {
            final isActive = index == vm.currentImageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
