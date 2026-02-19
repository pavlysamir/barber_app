import 'package:barber_app/features/employee/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/features/employee/managers/employee_cubit.dart';
import 'package:barber_app/features/employee/data/models/service_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/auth/managers/auth_cubit.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final List<ServiceModel> _selectedServices = [];
  final _customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeCubit>().loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار الخدمات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmployeeDashboardScreen(),
              ),
            );
          },
        ),
      ),
      body: BlocConsumer<EmployeeCubit, EmployeeState>(
        listener: (context, state) {
          if (state is EmployeeTransactionSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmployeeDashboardScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EmployeeServicesLoaded) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(labelText: 'اسم الزبون'),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: state.services.length,
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      final isSelected = _selectedServices.contains(service);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected
                                ? _selectedServices.remove(service)
                                : _selectedServices.add(service);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cut,
                                color: isSelected ? Colors.white : null,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                service.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                              Text(
                                '${service.price} جنيه',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = _selectedServices.fold<double>(0, (sum, s) => sum + s.price);
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الإجمالي'),
                Text(
                  '$total جنيه',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _selectedServices.isEmpty ? null : _submit,
            child: const Text('حفظ المعاملة'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final transaction = TransactionModel(
      id: '',
      employeeId: user.id,
      customerName: _customerNameController.text.isEmpty
          ? 'زبون'
          : _customerNameController.text,
      selectedServices: _selectedServices,
      totalPrice: _selectedServices.fold<double>(0, (sum, s) => sum + s.price),
      date: DateTime.now(),
    );
    context.read<EmployeeCubit>().submitTransaction(transaction);
  }
}
