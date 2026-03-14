// screens/product/product_detail_screen.dart
//
// Màn hình Chi tiết sản phẩm — MVVM Architecture
//
// Cấu trúc:
//   • ChangeNotifierProvider<ProductDetailViewModel> bao bọc toàn màn hình
//   • Scaffold với body = CustomScrollView (SliverList)
//   • bottomNavigationBar = ProductDetailBottomBar (cố định)
//
// Các widget con được tách riêng file trong thư mục widgets/:
//   • ProductImageSlider  — Hero + PageView + DotIndicator
//   • ProductPriceInfo    — Tên, Rating, Giá bán (đỏ), Giá gốc (gạch ngang)
//   • ProductVariationTile — Row phân loại + chevron_right → mở BottomSheet
//   • ProductDescription  — AnimatedCrossFade + Xem thêm / Thu gọn

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import 'product_detail_bottom_bar.dart';
import 'product_detail_bottom_sheet.dart';
import 'product_detail_view_model.dart';
import 'widgets/product_description.dart';
import 'widgets/product_image_slider.dart';
import 'widgets/product_price_info.dart';
import 'widgets/product_variation_tile.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    // ViewModel chỉ sống trong phạm vi màn hình này (local state)
    return ChangeNotifierProvider(
      create: (_) => ProductDetailViewModel(),
      child: _ProductDetailView(product: product),
    );
  }
}

// ─── View tách riêng để truy cập ViewModel qua context ─────────────────────
class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({required this.product});

  final Product product;

  void _openBottomSheet(BuildContext context) {
    showProductBottomSheet(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ── AppBar trong suốt nằm trên slider ──────────────────────
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _BackButton(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_outlined, size: 22),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border, size: 22),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ── Body: danh sách các khối nội dung ─────────────────────
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Slider ảnh (chiếm chiều cao 320 + padding appBar)
          SliverToBoxAdapter(
            child: ProductImageSlider(product: product),
          ),

          // Nội dung chính (padding top để tránh overlap AppBar)
          SliverList(
            delegate: SliverChildListDelegate([
              // Giá & Tên sản phẩm
              ProductPriceInfo(product: product),

              const _SectionDivider(),

              // Phân loại (mở BottomSheet khi tap)
              ProductVariationTile(
                onTap: () => _openBottomSheet(context),
              ),

              const SizedBox(height: 8),
              const _SectionDivider(),

              // Thông tin giao hàng nhanh
              _DeliveryInfoRow(),

              const _SectionDivider(),

              // Mô tả sản phẩm có Xem thêm / Thu gọn
              const SizedBox(height: 12),
              ProductDescription(description: product.description),

              // Khoảng trống cuối để không bị BottomBar che
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),

      // ── Bottom bar cố định ──────────────────────────────────────
      bottomNavigationBar: ProductDetailBottomBar(
        onAddToCart: () => _openBottomSheet(context),
        onBuyNow: () => _openBottomSheet(context),
        onChat: () {},
      ),
    );
  }
}

// ─── Back button với background trắng bán trong suốt ───────────────────────
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => Navigator.maybePop(context),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}

// ─── Thanh phân chia mỏng giữa các khối ────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
    );
  }
}

// ─── Row giao hàng nhanh ────────────────────────────────────────────────────
class _DeliveryInfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined,
              color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giao hàng nhanh',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dự kiến nhận trong 2–4 ngày làm việc',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4)),
        ],
      ),
    );
  }
}
