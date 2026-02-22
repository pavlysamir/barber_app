import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:barber_app/features/employee/data/models/service_model.dart';
import 'package:barber_app/features/admin/data/models/product_model.dart';

class TransactionModel extends Equatable {
  final String id;
  final String employeeId;
  final String customerName;
  final List<ServiceModel> selectedServices;
  final List<ProductModel> selectedProducts;
  final double totalPrice;
  final DateTime date;
  final String status; // 'active' or 'closed'

  const TransactionModel({
    required this.id,
    required this.employeeId,
    required this.customerName,
    required this.selectedServices,
    required this.selectedProducts,
    required this.totalPrice,
    required this.date,
    this.status = 'active',
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id,
      employeeId: json['employeeId'] as String,
      customerName: json['customerName'] as String,
      selectedServices: (json['selectedServices'] as List? ?? [])
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>, ''))
          .toList(),
      selectedProducts: (json['selectedProducts'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>, ''))
          .toList(),
      totalPrice: double.tryParse(json['totalPrice'].toString()) ?? 0.0,
      date: json['date'] != null
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'customerName': customerName,
      'selectedServices': selectedServices.map((e) => e.toJson()).toList(),
      'selectedProducts': selectedProducts.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    customerName,
    selectedServices,
    selectedProducts,
    totalPrice,
    date,
    status,
  ];
}
