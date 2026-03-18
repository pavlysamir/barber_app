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
  final List<ProductModel> products;
  const EmployeeServicesLoaded({required this.services, required this.products});

  @override
  List<Object?> get props => [services, products];
}
class EmployeeDashboardLoaded extends EmployeeState {
  final List<TransactionModel> transactions;
  final double todayTotal;
  final int customerCount;
  final double todayWithdrawn;
  final bool isWithdrawing; // 👈 جديد

  const EmployeeDashboardLoaded({
    required this.transactions,
    required this.todayTotal,
    required this.customerCount,
    this.todayWithdrawn = 0.0,
    this.isWithdrawing = false,
  });

  EmployeeDashboardLoaded copyWith({
    List<TransactionModel>? transactions,
    double? todayTotal,
    int? customerCount,
    double? todayWithdrawn,
    bool? isWithdrawing,
  }) {
    return EmployeeDashboardLoaded(
      transactions: transactions ?? this.transactions,
      todayTotal: todayTotal ?? this.todayTotal,
      customerCount: customerCount ?? this.customerCount,
      todayWithdrawn: todayWithdrawn ?? this.todayWithdrawn,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    todayTotal,
    customerCount,
    todayWithdrawn,
    isWithdrawing,
  ];
}

class EmployeeTransactionSuccess extends EmployeeState {}

class EmployeeWithdrawalSuccess extends EmployeeState {}

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}
