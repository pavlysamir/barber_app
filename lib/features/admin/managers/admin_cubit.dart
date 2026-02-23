import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:barber_app/features/auth/data/models/user_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/admin/data/repos/admin_repo.dart';
import 'package:barber_app/features/admin/data/models/product_model.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;
  StreamSubscription? _productSubscription;

  AdminCubit(this._repository) : super(AdminInitial());

  Future<void> loadEmployees() async {
    try {
      final employees = await _repository.getEmployees();
      emit(AdminEmployeesLoaded(employees));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  void listenToDailyReport(DateTime date) async {
    emit(AdminLoading());
    final employees = await _repository.getEmployees();
    final Map<String, UserModel> employeeMap = {
      for (var e in employees) e.id: e
    };
    final adminTallyCounts = await _repository.getAdminTallyCounts(date);

    _repository.getDailyTransactions(date).listen((transactions) {
      final totalAmount = transactions.fold<double>(
        0,
        (sum, t) => sum + t.totalPrice,
      );

      double productTotal = 0;
      final Map<String, double> employeeTotals = {};
      final Map<String, int> employeeCustomerCounts = {};

      for (var t in transactions) {
        // Calculate services total for this employee
        final serviceIncome =
            t.selectedServices.fold<double>(0, (sum, s) => sum + s.price);
        employeeTotals[t.employeeId] =
            (employeeTotals[t.employeeId] ?? 0) + serviceIncome;

        // Sum products for all transactions
        productTotal +=
            t.selectedProducts.fold<double>(0, (sum, p) => sum + p.price);

        employeeCustomerCounts[t.employeeId] =
            (employeeCustomerCounts[t.employeeId] ?? 0) + 1;
      }

      emit(
        AdminReportLoaded(
          transactions: transactions,
          totalAmount: totalAmount,
          productTotal: productTotal,
          employeeTotals: employeeTotals,
          employeeCustomerCounts: employeeCustomerCounts,
          employeeMap: employeeMap,
          adminTallyCounts: adminTallyCounts,
        ),
      );
    });
  }

  Future<void> closeEmployeeDay(String employeeId, DateTime date) async {
    try {
      await _repository.closeEmployeeTransactions(employeeId);
      // Refresh report
      listenToDailyReport(date);
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> addEmployee({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AdminLoading());
    try {
      await _repository.createEmployee(
        email: email,
        password: password,
        name: name,
      );
      emit(AdminAddEmployeeSuccess());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _repository.deleteEmployee(employeeId);
      // Refresh the report/list to reflect deletion
      listenToDailyReport(DateTime.now());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> incrementAdminCount(String employeeId) async {
    try {
      await _repository.incrementAdminCount(employeeId, DateTime.now());
      listenToDailyReport(DateTime.now());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> decrementAdminCount(String employeeId) async {
    try {
      await _repository.decrementAdminCount(employeeId, DateTime.now());
      listenToDailyReport(DateTime.now());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  // ── Products ──────────────────────────────────────────
  void loadProducts() {
    emit(AdminLoading());
    _productSubscription?.cancel();
    _productSubscription = _repository.getProducts().listen(
      (products) => emit(AdminProductsLoaded(products)),
      onError: (e) => emit(AdminError(e.toString())),
    );
  }

  Future<void> addProduct({
    required String name,
    required int count,
    required double price,
  }) async {
    try {
      await _repository.addProduct(name: name, count: count, price: price);
      emit(AdminProductSuccess());
      // No need to call loadProducts() again as the stream listener handles it
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      // No need to call loadProducts() again as the stream listener handles it
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
