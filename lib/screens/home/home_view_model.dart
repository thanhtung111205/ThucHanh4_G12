import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final List<Product> _allProducts = [];
  List<Product> _visibleProducts = [];

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 8;
  double _scrollOffset = 0;
  int _currentBanner = 0;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _error;

  String? get selectedCategory => _selectedCategory;

  List<Product> get _filteredAll {
    if (_selectedCategory == null) return _allProducts;
    return _allProducts.where((p) => p.category == _selectedCategory).toList();
  }

  List<Product> get products {
    var list = _selectedCategory == null ? _visibleProducts : _filteredAll;
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list
        .where((p) => p.title.toLowerCase().contains(query) || p.category.toLowerCase().contains(query))
        .toList();
  }

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get currentBanner => _currentBanner;
  String? get error => _error;

  double get appBarOpacity => (_scrollOffset / 140).clamp(0, 1);

  Future<void> loadInitial() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _apiService.fetchProducts();
      _allProducts
        ..clear()
        ..addAll(items);
      _page = 1;
      _visibleProducts = _allProducts.take(_pageSize).toList();
      _hasMore = _visibleProducts.length < _allProducts.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _apiService.fetchProducts();
      _allProducts
        ..clear()
        ..addAll(items);
      _page = 1;
      _visibleProducts = _allProducts.take(_pageSize).toList();
      _hasMore = _visibleProducts.length < _allProducts.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading || _allProducts.isEmpty) return;
    // Khi có category filter, dùng _filteredAll để phân trang đúng
    if (_selectedCategory != null) return; // filtered list dùng toàn bộ
    _isLoadingMore = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 200));
    _page += 1;
    final nextLimit = _page * _pageSize;
    _visibleProducts = _allProducts.take(nextLimit).toList();
    _hasMore = nextLimit < _allProducts.length;

    _isLoadingMore = false;
    notifyListeners();
  }

  void updateScrollOffset(double offset) {
    final num next = offset.clamp(0, double.infinity);
    final double nextValue = next.toDouble();
    if ((nextValue - _scrollOffset).abs() > 2) {
      _scrollOffset = nextValue;
      notifyListeners();
    }
  }

  void updateBannerIndex(int index) {
    _currentBanner = index;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  void selectCategory(String? category) {
    // Toggle: nếu bấm lại cùng category thì bỏ chọn (về tất cả)
    _selectedCategory = (_selectedCategory == category) ? null : category;
    // Reset pagination về trang 1 theo filter mới
    _page = 1;
    final source = _filteredAll;
    _visibleProducts = source.take(_pageSize).toList();
    _hasMore = _visibleProducts.length < source.length;
    notifyListeners();
  }
}
