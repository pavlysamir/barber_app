import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? icon;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.icon,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json, String id) {
    return ServiceModel(
      id: id,
      name: json['name'] as String,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, name, price, icon];
}
