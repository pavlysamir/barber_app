import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final int count;
  final double price;

  const ProductModel({
    required this.id,
    required this.name,
    required this.count,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    return ProductModel(
      id: id.isNotEmpty ? id : (json['id'] as String? ?? ''),
      name: json['name'] as String,
      count: (json['count'] as num).toInt(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, name, count, price];
}
