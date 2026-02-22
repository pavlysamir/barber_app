import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/features/auth/data/models/user_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/admin/data/models/product_model.dart';
import 'package:barber_app/core/utils/constants.dart';

abstract class AdminRepository {
  Future<List<UserModel>> getEmployees();
  Stream<List<TransactionModel>> getDailyTransactions(DateTime date);
  Stream<List<TransactionModel>> getEmployeeDailyTransactions(
    String employeeId,
    DateTime date,
  );
  Future<void> closeEmployeeTransactions(String employeeId);
  Future<void> createEmployee({
    required String email,
    required String password,
    required String name,
  });
  Future<void> deleteEmployee(String employeeId);
  Future<void> incrementAdminCount(String employeeId, DateTime date);
  Future<void> decrementAdminCount(String employeeId, DateTime date);
  Future<Map<String, int>> getAdminTallyCounts(DateTime date);
  // Products
  Stream<List<ProductModel>> getProducts();
  Future<void> addProduct({required String name, required int count, required double price});
  Future<void> deleteProduct(String productId);
  Future<void> decrementProductStock(String productId, int quantity);
}

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AdminRepositoryImpl({required this.firestore, required this.auth});

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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<TransactionModel>> getEmployeeDailyTransactions(
    String employeeId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return firestore
        .collection(AppConstants.transactionsCollection)
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
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

  @override
  Future<void> createEmployee({
    required String email,
    required String password,
    required String name,
  }) async {
    // To create a user without signing out the current admin, we use a secondary Firebase app instance
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(
        app: secondaryApp,
      ).createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final newUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          role: UserRole.employee,
        );

        await firestore
            .collection(AppConstants.usersCollection)
            .doc(newUser.id)
            .set(newUser.toJson());
      }
    } finally {
      await secondaryApp.delete();
    }
  }

  @override
  Future<void> deleteEmployee(String employeeId) async {
    print(employeeId);
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(employeeId)
        .delete();
  }

  String _tallyDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<void> incrementAdminCount(String employeeId, DateTime date) async {
    final ref = firestore
        .collection('daily_tallies')
        .doc(_tallyDateKey(date))
        .collection('employees')
        .doc(employeeId);
    await ref.set(
      {'adminCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> decrementAdminCount(String employeeId, DateTime date) async {
    final ref = firestore
        .collection('daily_tallies')
        .doc(_tallyDateKey(date))
        .collection('employees')
        .doc(employeeId);
    final snap = await ref.get();
    final current = (snap.data()?['adminCount'] as int?) ?? 0;
    if (current > 0) {
      await ref.set(
        {'adminCount': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
    }
  }

  @override
  Future<Map<String, int>> getAdminTallyCounts(DateTime date) async {
    final snapshot = await firestore
        .collection('daily_tallies')
        .doc(_tallyDateKey(date))
        .collection('employees')
        .get();
    return {
      for (var doc in snapshot.docs)
        doc.id: (doc.data()['adminCount'] as int?) ?? 0,
    };
  }

  @override
  Stream<List<ProductModel>> getProducts() {
    return firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> addProduct({
    required String name,
    required int count,
    required double price,
  }) async {
    await firestore.collection('products').add({
      'name': name,
      'count': count,
      'price': price,
    });
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await firestore.collection('products').doc(productId).delete();
  }

  @override
  Future<void> decrementProductStock(String productId, int quantity) async {
    await firestore.collection('products').doc(productId).update({
      'count': FieldValue.increment(-quantity),
    });
  }
}
