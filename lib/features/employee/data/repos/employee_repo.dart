import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/features/employee/data/models/service_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/core/utils/constants.dart';

abstract class EmployeeRepository {
  Future<List<ServiceModel>> getServices();
  Future<void> saveTransaction(TransactionModel transaction);
  Stream<List<TransactionModel>> getTodayTransactions(String employeeId);
}

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseFirestore firestore;

  EmployeeRepositoryImpl({required this.firestore});

  @override
  Future<List<ServiceModel>> getServices() async {
    final snapshot = await firestore.collection(AppConstants.servicesCollection).get();
    return snapshot.docs
        .map((doc) => ServiceModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    await firestore
        .collection(AppConstants.transactionsCollection)
        .add(transaction.toJson());
  }

  @override
  Stream<List<TransactionModel>> getTodayTransactions(String employeeId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return firestore
        .collection(AppConstants.transactionsCollection)
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('status', isEqualTo: 'active')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
