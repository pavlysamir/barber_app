import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:barber_app/features/employee/data/models/service_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/employee/data/repos/employee_repo.dart';

part 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeRepository _repository;
  StreamSubscription? _transactionSubscription;

  EmployeeCubit(this._repository) : super(EmployeeInitial());

  Future<void> loadServices() async {
    emit(EmployeeLoading());
    try {
      final services = await _repository.getServices();
      emit(EmployeeServicesLoaded(services));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  void listenToTodayTransactions(String employeeId) {
    _transactionSubscription?.cancel();
    _transactionSubscription = _repository.getTodayTransactions(employeeId).listen(
      (transactions) {
        final todayTotal = transactions.fold<double>(0, (sum, t) => sum + t.totalPrice);
        emit(EmployeeDashboardLoaded(
          transactions: transactions,
          todayTotal: todayTotal,
          customerCount: transactions.length,
        ));
      },
      onError: (error) {
        emit(EmployeeError('Firestore Error: ${error.toString()}'));
      },
    );
  }

  Future<void> submitTransaction(TransactionModel transaction) async {
    emit(EmployeeLoading());
    try {
      await _repository.saveTransaction(transaction);
      emit(EmployeeTransactionSuccess());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
