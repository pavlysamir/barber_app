part of 'admin_cubit.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminEmployeesLoaded extends AdminState {
  final List<UserModel> employees;
  const AdminEmployeesLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

class AdminReportLoaded extends AdminState {
  final List<TransactionModel> transactions;
  final double totalAmount;
  final Map<String, double> employeeTotals;
  final Map<String, int> employeeCustomerCounts;
  final Map<String, UserModel> employeeMap;

  const AdminReportLoaded({
    required this.transactions,
    required this.totalAmount,
    required this.employeeTotals,
    required this.employeeCustomerCounts,
    required this.employeeMap,
  });

  @override
  List<Object?> get props =>
      [transactions, totalAmount, employeeTotals, employeeCustomerCounts, employeeMap];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminAddEmployeeSuccess extends AdminState {}
