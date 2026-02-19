import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:barber_app/features/auth/data/models/user_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/admin/data/repos/admin_repo.dart';

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

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

    _repository.getDailyTransactions(date).listen((transactions) {
      final totalAmount = transactions.fold<double>(
        0,
        (sum, t) => sum + t.totalPrice,
      );

      final Map<String, double> employeeTotals = {};
      final Map<String, int> employeeCustomerCounts = {};

      for (var t in transactions) {
        employeeTotals[t.employeeId] =
            (employeeTotals[t.employeeId] ?? 0) + t.totalPrice;
        employeeCustomerCounts[t.employeeId] =
            (employeeCustomerCounts[t.employeeId] ?? 0) + 1;
      }

      emit(
        AdminReportLoaded(
          transactions: transactions,
          totalAmount: totalAmount,
          employeeTotals: employeeTotals,
          employeeCustomerCounts: employeeCustomerCounts,
          employeeMap: employeeMap,
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
}
