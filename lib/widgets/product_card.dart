import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
	const ProductCard({
		super.key,
		required this.product,
		required this.onAddToCart,
		this.onTap,
	});

	final Product product;
	final VoidCallback onAddToCart;
	final VoidCallback? onTap;

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);

		return InkWell(
			onTap: onTap ?? () {
				Navigator.push<void>(
					context,
					MaterialPageRoute(
						builder: (_) => ProductDetailScreen(product: product),
					),
				);
			},
			borderRadius: BorderRadius.circular(16),
			child: Card(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				elevation: 3,
				child: Padding(
					padding: const EdgeInsets.all(12),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: ClipRRect(
									borderRadius: BorderRadius.circular(12),
									child: AspectRatio(
										aspectRatio: 1,
										child: Hero(
											tag: 'product-image-${product.id}',
											child: Container(
												color: theme.colorScheme.surfaceVariant,
												child: Image.network(
													product.image,
													fit: BoxFit.contain,
													errorBuilder: (context, _, __) => const Icon(Icons.image_not_supported),
												),
											),
										),
									),
								),
							),
							const SizedBox(height: 10),
							Text(
								product.title,
								maxLines: 2,
								overflow: TextOverflow.ellipsis,
								style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
							),
							const SizedBox(height: 6),
							Row(
								children: [
									Icon(Icons.star, color: Colors.amber.shade700, size: 18),
									const SizedBox(width: 4),
									Text('${product.rating.toStringAsFixed(1)} (${product.ratingCount})'),
								],
							),
							const Spacer(),
							Row(
								children: [
									Text(
										'\$${product.price.toStringAsFixed(2)}',
										style: theme.textTheme.titleMedium?.copyWith(
											fontWeight: FontWeight.bold,
											color: theme.colorScheme.primary,
										),
									),
									const Spacer(),
									ElevatedButton.icon(
										style: ElevatedButton.styleFrom(
											elevation: 0,
											padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
										),
										onPressed: onAddToCart,
										icon: const Icon(Icons.add_shopping_cart, size: 18),
										label: const Text('Thêm'),
									),
								],
							),
						],
					),
				),
			),
		);
	}
}
