import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WithdrawalModel extends Equatable {
  final String id;
  final String employeeId;
  final double amount;
  final DateTime date;
  final String note;

  const WithdrawalModel({
    required this.id,
    required this.employeeId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json, String id) {
    return WithdrawalModel(
      id: id,
      employeeId: json['employeeId'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] != null
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }

  @override
  List<Object?> get props => [id, employeeId, amount, date, note];
}
