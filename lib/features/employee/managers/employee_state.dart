part of 'employee_cubit.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeServicesLoaded extends EmployeeState {
  final List<ServiceModel> services;
  const EmployeeServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class EmployeeDashboardLoaded extends EmployeeState {
  final List<TransactionModel> transactions;
  final double todayTotal;
  final int customerCount;

  const EmployeeDashboardLoaded({
    required this.transactions,
    required this.todayTotal,
    required this.customerCount,
  });

  @override
  List<Object?> get props => [transactions, todayTotal, customerCount];
}

class EmployeeTransactionSuccess extends EmployeeState {}

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}
