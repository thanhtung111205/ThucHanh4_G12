import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const String _storageKey = 'cart_items_v1';
  final Map<String, CartItem> _items = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _restoreFromStorage();
  }

  List<CartItem> get items => List.unmodifiable(_items.values);

  int get totalItemTypes => _items.length;

  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get selectedItemTypes =>
      _items.values.where((item) => item.isSelected).length;

  bool get isAllSelected =>
      _items.isNotEmpty && _items.values.every((item) => item.isSelected);

  double get selectedTotalPrice => _items.values
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.lineTotal);

  List<CartItem> get selectedItems =>
      _items.values.where((item) => item.isSelected).toList(growable: false);

  String _itemKey(int productId, String? size, String? color) {
    final normalizedSize = (size ?? 'default').trim().toLowerCase();
    final normalizedColor = (color ?? 'default').trim().toLowerCase();
    return '$productId|$normalizedSize|$normalizedColor';
  }

  void addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  }) {
    final safeQuantity = quantity <= 0 ? 1 : quantity;
    final key = _itemKey(product.id, size, color);
    final existing = _items[key];
    if (existing == null) {
      _items[key] = CartItem(
        id: key,
        product: product,
        quantity: safeQuantity,
        isSelected: true,
        size: size,
        color: color,
      );
    } else {
      _items[key] = existing.copyWith(
        quantity: existing.quantity + safeQuantity,
        isSelected: true,
      );
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeItemById(String itemId) {
    _items.remove(itemId);
    _saveToStorage();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((_, item) => item.product.id == productId);
    _saveToStorage();
    notifyListeners();
  }

  void toggleItemSelection(String itemId, bool isSelected) {
    final item = _items[itemId];
    if (item == null) return;
    _items[itemId] = item.copyWith(isSelected: isSelected);
    _saveToStorage();
    notifyListeners();
  }

  void toggleSelectAll(bool selectAll) {
    if (_items.isEmpty) return;
    _items.updateAll((_, item) => item.copyWith(isSelected: selectAll));
    _saveToStorage();
    notifyListeners();
  }

  void increaseQuantity(String itemId) {
    final item = _items[itemId];
    if (item == null) return;
    _items[itemId] = item.copyWith(quantity: item.quantity + 1);
    _saveToStorage();
    notifyListeners();
  }

  void decreaseQuantity(String itemId) {
    final item = _items[itemId];
    if (item == null) return;
    if (item.quantity <= 1) {
      removeItemById(itemId);
      return;
    }
    _items[itemId] = item.copyWith(quantity: item.quantity - 1);
    _saveToStorage();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    String? key;
    CartItem? item;
    for (final entry in _items.entries) {
      if (entry.value.product.id == productId) {
        key = entry.key;
        item = entry.value;
        break;
      }
    }
    if (key == null || item == null) return;
    if (quantity <= 0) {
      _items.remove(key);
    } else {
      _items[key] = item.copyWith(quantity: quantity);
    }
    _saveToStorage();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _restoreFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.trim().isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      _items.clear();
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final item = CartItem.fromJson(Map<String, dynamic>.from(entry));
        if (item.id.isEmpty || item.quantity <= 0) continue;
        _items[item.id] = item;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _items.values.map((item) => item.toJson()).toList(growable: false),
      );
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }
}
