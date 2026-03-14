// screens/product/product_detail_view_model.dart
//
// ViewModel quản lý trạng thái cục bộ của màn hình Product Detail.
// Tuân theo MVVM: View (Screen/Widgets) không chứa business logic,
// tất cả state mutation thực hiện qua ViewModel.

import 'package:flutter/material.dart';

class ProductDetailViewModel extends ChangeNotifier {
  // ── Variation state ──────────────────────────────────────────────
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  String? get selectedSize => _selectedSize;
  String? get selectedColor => _selectedColor;
  int get quantity => _quantity;

  void selectSize(String size) {
    if (_selectedSize == size) return;
    _selectedSize = size;
    notifyListeners();
  }

  void selectColor(String color) {
    if (_selectedColor == color) return;
    _selectedColor = color;
    notifyListeners();
  }

  void increment() {
    _quantity++;
    notifyListeners();
  }

  void decrement() {
    if (_quantity <= 1) return;
    _quantity--;
    notifyListeners();
  }

  void resetSelections() {
    _selectedSize = null;
    _selectedColor = null;
    _quantity = 1;
    notifyListeners();
  }

  // ── Description expand/collapse ──────────────────────────────────
  bool _isDescriptionExpanded = false;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  void toggleDescription() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  // ── Image slider page indicator ──────────────────────────────────
  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  void updateImageIndex(int index) {
    if (_currentImageIndex == index) return;
    _currentImageIndex = index;
    notifyListeners();
  }

  // ── Human-readable variation summary (hiển thị trên tile) ────────
  String get variationSummary {
    final parts = <String>[];
    if (_selectedSize != null) parts.add(_selectedSize!);
    if (_selectedColor != null) parts.add(_selectedColor!);
    return parts.isEmpty ? 'Chưa chọn' : parts.join(', ');
  }
}
