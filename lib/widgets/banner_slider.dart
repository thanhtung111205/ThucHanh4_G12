// widgets/banner_slider.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
	const BannerSlider({
		super.key,
		required this.banners,
		required this.currentIndex,
		required this.onPageChanged,
	});

	final List<String> banners;
	final int currentIndex;
	final ValueChanged<int> onPageChanged;

	@override
	State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		return Column(
			children: [
				const SizedBox(height: 12),
				CarouselSlider.builder(
					itemCount: widget.banners.length,
					itemBuilder: (_, index, __) {
						return Padding(
							padding: const EdgeInsets.symmetric(horizontal: 12),
							child: ClipRRect(
								borderRadius: BorderRadius.circular(16),
								child: Stack(
									fit: StackFit.expand,
									children: [
										Image.network(widget.banners[index], fit: BoxFit.cover),
										Container(
											decoration: const BoxDecoration(
												gradient: LinearGradient(
													colors: [Colors.black54, Colors.transparent],
													begin: Alignment.bottomCenter,
													end: Alignment.topCenter,
												),
											),
										),
									],
								),
							),
						);
					},
					options: CarouselOptions(
						height: 180,
						autoPlay: true,
						viewportFraction: 0.9,
						enlargeCenterPage: true,
						onPageChanged: (index, _) => widget.onPageChanged(index),
					),
				),
				const SizedBox(height: 8),
				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: List.generate(widget.banners.length, (index) {
						final isActive = index == widget.currentIndex;
						return AnimatedContainer(
							duration: const Duration(milliseconds: 300),
							margin: const EdgeInsets.symmetric(horizontal: 4),
							height: 8,
							width: isActive ? 22 : 8,
							decoration: BoxDecoration(
								color: isActive
										? theme.colorScheme.primary
										: theme.colorScheme.onSurface.withOpacity(0.3),
								borderRadius: BorderRadius.circular(12),
							),
						);
					}),
				),
				const SizedBox(height: 4),
			],
		);
	}
}
