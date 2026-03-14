import 'package:flutter/material.dart';

import '../models/product.dart';

class CartProvider extends ChangeNotifier {
	final Map<int, int> _items = {};

	Map<int, int> get items => Map.unmodifiable(_items);

	int get totalItemTypes => _items.length;

	int get totalQuantity => _items.values.fold(0, (sum, qty) => sum + qty);

	double totalPrice(Map<int, Product> productLookup) {
		double total = 0;
		_items.forEach((id, qty) {
			final product = productLookup[id];
			if (product != null) {
				total += product.price * qty;
			}
		});
		return total;
	}

	void addToCart(Product product, {int quantity = 1}) {
		final current = _items[product.id] ?? 0;
		_items[product.id] = current + quantity;
		notifyListeners();
	}

	void removeFromCart(int productId) {
		_items.remove(productId);
		notifyListeners();
	}

	void updateQuantity(int productId, int quantity) {
		if (quantity <= 0) {
			_items.remove(productId);
		} else {
			_items[productId] = quantity;
		}
		notifyListeners();
	}

	void clear() {
		_items.clear();
		notifyListeners();
	}
}
