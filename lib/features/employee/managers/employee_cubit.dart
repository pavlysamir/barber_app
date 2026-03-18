import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:barber_app/features/employee/data/models/service_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/employee/data/models/withdrawal_model.dart';
import 'package:barber_app/features/admin/data/models/product_model.dart';
import 'package:barber_app/features/employee/data/repos/employee_repo.dart';

part 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeRepository _repository;
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _withdrawalSubscription;

  // Keep latest values for combining streams
  List<TransactionModel> _latestTransactions = [];
  double _latestWithdrawn = 0.0;

  EmployeeCubit(this._repository) : super(EmployeeInitial());

  Future<void> loadServicesAndProducts() async {
    emit(EmployeeLoading());
    try {
      final services = await _repository.getServices();
      final products = await _repository.getProducts();
      emit(EmployeeServicesLoaded(services: services, products: products));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  void listenToTodayTransactions(String employeeId) {
    _transactionSubscription?.cancel();
    _withdrawalSubscription?.cancel();

    // Listen to withdrawals
    _withdrawalSubscription = _repository
        .getTodayWithdrawals(employeeId)
        .listen(
          (withdrawals) {
            _latestWithdrawn = withdrawals.fold(
              0.0,
              (sum, w) => sum + w.amount,
            );
            _emitDashboard();
          },
          onError: (error) {
            emit(EmployeeError('Firestore Error: ${error.toString()}'));
          },
        );

    // Listen to transactions
    _transactionSubscription = _repository
        .getTodayTransactions(employeeId)
        .listen(
          (transactions) {
            _latestTransactions = transactions;
            _emitDashboard();
          },
          onError: (error) {
            emit(EmployeeError('Firestore Error: ${error.toString()}'));
          },
        );
  }

  void _emitDashboard() {
    final currentState = state;

    bool isWithdrawing = false;
    if (currentState is EmployeeDashboardLoaded) {
      isWithdrawing = currentState.isWithdrawing;
    }

    final todayTotal = _latestTransactions.fold<double>(
      0,
      (sum, t) =>
          sum + t.selectedServices.fold<double>(0, (sSum, s) => sSum + s.price),
    );

    emit(
      EmployeeDashboardLoaded(
        transactions: _latestTransactions,
        todayTotal: todayTotal,
        customerCount: _latestTransactions.length,
        todayWithdrawn: _latestWithdrawn,
        isWithdrawing: isWithdrawing, // 👈 مهم
      ),
    );
  }

  Future<void> submitTransaction(TransactionModel transaction) async {
    emit(EmployeeLoading());
    try {
      await _repository.saveTransaction(transaction);
      for (var product in transaction.selectedProducts) {
        await _repository.decrementProductStock(product.id, 1);
      }
      emit(EmployeeTransactionSuccess());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> submitWithdrawal({
    required String employeeId,
    required double amount,
    String note = '',
  }) async {
    final currentState = state;

    if (currentState is EmployeeDashboardLoaded) {
      emit(currentState.copyWith(isWithdrawing: true));
    }

    try {
      final withdrawal = WithdrawalModel(
        id: '',
        employeeId: employeeId,
        amount: amount,
        date: DateTime.now(),
        note: note,
      );

      await _repository.saveWithdrawal(withdrawal);

      // ❌ متعملش emit success
      // emit(EmployeeWithdrawalSuccess());

      if (state is EmployeeDashboardLoaded) {
        emit((state as EmployeeDashboardLoaded).copyWith(isWithdrawing: false));
      }
    } catch (e) {
      if (state is EmployeeDashboardLoaded) {
        emit((state as EmployeeDashboardLoaded).copyWith(isWithdrawing: false));
      }
      emit(EmployeeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _withdrawalSubscription?.cancel();
    return super.close();
  }
}
