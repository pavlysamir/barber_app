import 'package:animate_do/animate_do.dart';
import 'package:barber_app/core/cashe/cache_helper.dart';
import 'package:barber_app/core/cashe/cashe_constance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/features/employee/managers/employee_cubit.dart';
import 'package:barber_app/features/auth/managers/auth_cubit.dart';
import 'package:barber_app/features/employee/presentation/screens/service_selection_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    context.read<EmployeeCubit>().listenToTodayTransactions(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = CacheHelper.getString(key: CacheConstants.firstName);
    return Scaffold(
      appBar: AppBar(
        title: SlideInRight(
          delay: const Duration(milliseconds: 300),
          from: 8,
          child: Text('لوحة الموظف\n $employeeName'),
        ),
        automaticallyImplyLeading: false,
        actions: [
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthLogout) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<AuthCubit>().logout(),
              );
            },
          ),
        ],
      ),
      body: BlocListener<EmployeeCubit, EmployeeState>(
        listener: (context, state) {
          if (state is EmployeeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<EmployeeCubit, EmployeeState>(
          builder: (context, state) {
            if (state is EmployeeDashboardLoaded) {
              return RefreshIndicator(
                backgroundColor: Colors.blue,
                color: Colors.black,
                onRefresh: () async {
                  final user =
                      (context.read<AuthCubit>().state as AuthAuthenticated)
                          .user;
                  context.read<EmployeeCubit>().listenToTodayTransactions(
                    user.id,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCard(state.todayTotal, state.customerCount),
                      SizedBox(height: 24.h),
                      SlideInRight(
                        delay: const Duration(milliseconds: 300),
                        from: 8,
                        child: const Text(
                          'المعاملات الأخيرة',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: state.transactions.isEmpty
                            ? const Center(child: Text('لا يوجد معاملات اليوم'))
                            : ListView.builder(
                                itemCount: state.transactions.length,
                                itemBuilder: (context, index) {
                                  final t = state.transactions[index];
                                  return ListTile(
                                    title: Text(t.customerName),
                                    subtitle: Text(
                                      '${t.selectedServices.length} خدمات',
                                    ),
                                    trailing: Text('${t.totalPrice} جنيه'),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is EmployeeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(state.message),
                    TextButton(
                      onPressed: () {
                        final user =
                            (context.read<AuthCubit>().state
                                    as AuthAuthenticated)
                                .user;
                        context.read<EmployeeCubit>().listenToTodayTransactions(
                          user.id,
                        );
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()),
          );
        },
        label: SlideInRight(
          delay: const Duration(milliseconds: 300),
          from: 8,
          child: const Text('إضافة زبون'),
        ),
        icon: SlideInRight(
          delay: const Duration(milliseconds: 300),
          from: 8,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStatsCard(double total, int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SlideInDown(
        delay: const Duration(milliseconds: 300),
        from: 8,
        child: Column(
          children: [
            Text(
              'إجمالي دخل اليوم',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
            Text(
              '$total جنيه',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'عدد الزبائن: $count',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
