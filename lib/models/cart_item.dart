import 'product.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.isSelected,
    this.size,
    this.color,
  });

  final String id;
  final Product product;
  final int quantity;
  final bool isSelected;
  final String? size;
  final String? color;

  double get lineTotal => product.price * quantity;

  String get variationText {
    final parts = <String>[];
    if (size != null && size!.trim().isNotEmpty) {
      parts.add('Size: ${size!.trim()}');
    }
    if (color != null && color!.trim().isNotEmpty) {
      parts.add('Màu: ${color!.trim()}');
    }
    return parts.isEmpty ? 'Phân loại: Mặc định' : parts.join(' · ');
  }

  CartItem copyWith({
    int? quantity,
    bool? isSelected,
    String? size,
    String? color,
  }) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'isSelected': isSelected,
      'size': size,
      'color': color,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as String?)?.trim() ?? '',
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isSelected: json['isSelected'] as bool? ?? false,
      size: (json['size'] as String?)?.trim(),
      color: (json['color'] as String?)?.trim(),
    );
  }
}
