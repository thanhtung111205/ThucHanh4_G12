import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
	static const _baseUrl = 'https://fakestoreapi.com';

	Future<List<Product>> fetchProducts() async {
		final uri = Uri.parse('$_baseUrl/products');
		final response = await http.get(uri);

		if (response.statusCode != 200) {
			throw Exception('Failed to load products (status ${response.statusCode})');
		}

		final data = jsonDecode(response.body) as List<dynamic>;
		return data.map((raw) => Product.fromJson(raw as Map<String, dynamic>)).toList();
	}
}
