import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../order_history/order_history_screen.dart';
import '../../widgets/product_card.dart';
import '../../widgets/banner_slider.dart';
import 'home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;
  final List<String> _banners = const [
    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800&q=80',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80',
    'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800&q=80',
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80',
  ];

  final List<_CategoryItem> _categories = const [
    _CategoryItem(
      icon: Icons.checkroom,
      label: 'Fashion',
      apiCategory: "men's clothing",
    ),
    _CategoryItem(
      icon: Icons.phone_android,
      label: 'Phones',
      apiCategory: 'electronics',
    ),
    _CategoryItem(
      icon: Icons.face_retouching_natural,
      label: 'Beauty',
      apiCategory: "women's clothing",
    ),
    _CategoryItem(icon: Icons.weekend, label: 'Furniture', apiCategory: null),
    _CategoryItem(
      icon: Icons.sports_soccer,
      label: 'Sports',
      apiCategory: null,
    ),
    _CategoryItem(icon: Icons.toys, label: 'Toys', apiCategory: null),
    _CategoryItem(
      icon: Icons.diamond,
      label: 'Jewelry',
      apiCategory: 'jewelery',
    ),
    _CategoryItem(
      icon: Icons.local_grocery_store,
      label: 'Groceries',
      apiCategory: null,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => context.read<HomeViewModel>().loadInitial());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              viewModel.updateScrollOffset(notification.metrics.pixels);
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 240) {
                viewModel.loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(theme, viewModel),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    minExtent: 72,
                    maxExtent: 88,
                    controller: _searchController,
                    onChanged: viewModel.updateSearchQuery,
                  ),
                ),
                SliverToBoxAdapter(child: _buildCarousel(viewModel, theme)),
                SliverToBoxAdapter(child: _buildCategories(theme)),
                _buildProducts(viewModel, theme),
                SliverToBoxAdapter(
                  child: _buildLoadMoreIndicator(viewModel, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, HomeViewModel viewModel) {
    final color = theme.colorScheme.primary.withOpacity(
      viewModel.appBarOpacity,
    );
    final foreground = viewModel.appBarOpacity > 0.5
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: color,
      elevation: viewModel.appBarOpacity > 0.6 ? 2 : 0,
      foregroundColor: foreground,
      title: const Text('TH4 - Nhóm 12'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            );
          },
          icon: const Icon(Icons.history),
          tooltip: 'Lịch sử mua hàng',
        ),
        Consumer<CartProvider>(
          builder: (_, cart, __) {
            return IconButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: badges.Badge(
                showBadge: cart.totalItemTypes > 0,
                position: badges.BadgePosition.topEnd(top: -4, end: -4),
                badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                badgeContent: Text(
                  cart.totalItemTypes.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.7),
                theme.colorScheme.primary.withOpacity(0.4),
                theme.scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hello, welcome back!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Find the best deals today.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(HomeViewModel viewModel, ThemeData theme) {
    return BannerSlider(
      banners: _banners,
      currentIndex: viewModel.currentBanner,
      onPageChanged: viewModel.updateBannerIndex,
    );
  }

  Widget _buildCategoryChip(
    _CategoryItem item,
    ThemeData theme, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : theme.colorScheme.primary.withOpacity(0.12),
              foregroundColor: isSelected
                  ? Colors.white
                  : theme.colorScheme.primary,
              child: Icon(item.icon, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    final viewModel = context.read<HomeViewModel>();
    final selected = context.watch<HomeViewModel>().selectedCategory;

    // All chip
    Widget allChip = GestureDetector(
      onTap: () => viewModel.selectCategory(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected == null
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected == null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: selected == null ? 1.5 : 1,
          ),
          boxShadow: selected == null
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: selected == null
                  ? Colors.white.withOpacity(0.25)
                  : theme.colorScheme.primary.withOpacity(0.12),
              foregroundColor: selected == null
                  ? Colors.white
                  : theme.colorScheme.primary,
              child: const Icon(Icons.apps, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'All',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected == null ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );

    // Build list including \"All\" chip at front
    final allItems = [null, ..._categories]; // null = All
    final List<Widget> row1Chips = [];
    final List<Widget> row2Chips = [];
    for (int i = 0; i < allItems.length; i++) {
      final item = allItems[i];
      final Widget chip = item == null
          ? Padding(padding: const EdgeInsets.only(right: 10), child: allChip)
          : Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildCategoryChip(
                item,
                theme,
                isSelected: selected != null && item.apiCategory == selected,
                onTap: () => viewModel.selectCategory(item.apiCategory),
              ),
            );
      if (i.isEven) {
        row1Chips.add(chip);
      } else {
        row2Chips.add(chip);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: row1Chips),
            const SizedBox(height: 10),
            Row(children: row2Chips),
          ],
        ),
      ),
    );
  }

  Widget _buildProducts(HomeViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (viewModel.error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load data'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: viewModel.loadInitial,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final products = viewModel.products;
    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 48),
            SizedBox(height: 10),
            Text('No products found'),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onAddToCart: () => context.read<CartProvider>().addToCart(product),
            // onTap không truyền → ProductCard tự navigate sang ProductDetailScreen
          );
        }, childCount: products.length),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(HomeViewModel viewModel, ThemeData theme) {
    if (!viewModel.isLoadingMore) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  _SearchBarDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.controller,
    required this.onChanged,
  }) : assert(maxExtent >= minExtent);

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final height = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);
    return Container(
      color: theme.scaffoldBackgroundColor,
      height: height,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Search products',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return controller != oldDelegate.controller ||
        minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        onChanged != oldDelegate.onChanged;
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.label,
    this.apiCategory,
  });

  final IconData icon;
  final String label;

  /// Khớp với trường category trong FakeStore API (null = không lọc được)
  final String? apiCategory;
}
