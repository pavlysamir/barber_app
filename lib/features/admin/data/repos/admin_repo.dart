import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/features/auth/data/models/user_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/core/utils/constants.dart';

abstract class AdminRepository {
  Future<List<UserModel>> getEmployees();
  Stream<List<TransactionModel>> getDailyTransactions(DateTime date);
  Stream<List<TransactionModel>> getEmployeeDailyTransactions(String employeeId, DateTime date);
  Future<void> closeEmployeeTransactions(String employeeId);
}

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore firestore;

  AdminRepositoryImpl({required this.firestore});

  @override
  Future<List<UserModel>> getEmployees() async {
    final snapshot = await firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'employee')
        .get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  @override
  Stream<List<TransactionModel>> getDailyTransactions(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return firestore
        .collection(AppConstants.transactionsCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<TransactionModel>> getEmployeeDailyTransactions(String employeeId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return firestore
        .collection(AppConstants.transactionsCollection)
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> closeEmployeeTransactions(String employeeId) async {
    final snapshot = await firestore
        .collection(AppConstants.transactionsCollection)
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'active')
        .get();

    final batch = firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'closed'});
    }
    await batch.commit();
  }
}
