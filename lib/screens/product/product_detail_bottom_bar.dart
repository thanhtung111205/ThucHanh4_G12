// screens/product/product_detail_bottom_bar.dart
//
// Bottom bar cố định, chia 2 nửa theo chiều ngang:
//   Trái  → IconButton Chat + IconButton Giỏ hàng (với Badge từ CartProvider)
//   Phải  → TextButton "Thêm vào giỏ" + ElevatedButton "Mua ngay"

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';

class ProductDetailBottomBar extends StatelessWidget {
  const ProductDetailBottomBar({
    super.key,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onChat,
  });

  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Nửa trái: Chat + Cart icon ──────────────────────────
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _IconActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    onTap: onChat,
                  ),
                  const VerticalDivider(width: 1, indent: 8, endIndent: 8),
                  Consumer<CartProvider>(
                    builder: (_, cart, __) => _IconActionButton(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Giỏ hàng',
                      badgeCount: cart.totalQuantity,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Divider dọc giữa 2 nửa
            const VerticalDivider(width: 1, indent: 4, endIndent: 4),

            // ── Nửa phải: Thêm vào giỏ + Mua ngay ─────────────────
            Expanded(
              child: Row(
                children: [
                  // "Thêm vào giỏ" – outlined / secondary style
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: onAddToCart,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Thêm\nvào giỏ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // "Mua ngay" – primary filled
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: onBuyNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mua\nngay',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Icon + Label + Badge nhỏ gọn ────────────────────────────────────────────
class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badges.Badge(
              showBadge: badgeCount > 0,
              position: badges.BadgePosition.topEnd(top: -6, end: -6),
              badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
              badgeContent: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              child: Icon(icon, size: 26, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
