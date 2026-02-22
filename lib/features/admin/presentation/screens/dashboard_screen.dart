import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/features/admin/managers/admin_cubit.dart';
import 'package:barber_app/features/auth/managers/auth_cubit.dart';
import 'package:barber_app/features/admin/presentation/screens/employee_details_screen.dart';
import 'package:barber_app/features/admin/presentation/screens/add_employee_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().listenToDailyReport(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SlideInRight(
          delay: const Duration(milliseconds: 300),
          from: 8,
          child: const Text('لوحة التحكم'),
        ),
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
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة موظف'),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {},
        buildWhen: (previous, current) {
          return current is AdminLoading ||
              current is AdminReportLoaded ||
              current is AdminError;
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminReportLoaded) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(state.totalAmount),
                  SizedBox(height: 24.h),
                  SlideInRight(
                    delay: const Duration(milliseconds: 300),
                    from: 8,
                    child: Text(
                      'أداء الموظفين',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.employeeMap.length,
                      itemBuilder: (context, index) {
                        final employeeId =
                            state.employeeMap.keys.elementAt(index);
                        final employee = state.employeeMap[employeeId]!;
                        final total =
                            state.employeeTotals[employeeId] ?? 0.0;
                        final employeeCount =
                            state.employeeCustomerCounts[employeeId] ?? 0;
                        final adminCount =
                            state.adminTallyCounts[employeeId] ?? 0;
                        final isMatch = adminCount == employeeCount;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(
                              color: adminCount == 0
                                  ? Colors.transparent
                                  : isMatch
                                      ? Colors.green
                                      : Colors.redAccent,
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeDetailsScreen(
                                    employeeId: employeeId,
                                    employeeName: employee.name,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row 1: avatar + name + delete
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        child: Text(
                                          employee.name.isNotEmpty
                                              ? employee.name.substring(0, 1)
                                              : 'M',
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          employee.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$total جنيه',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () =>
                                            _showDeleteConfirmation(
                                          context,
                                          employeeId,
                                          employee.name,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 12.h),
                                  // Row 2: admin tally controls vs employee count
                                  Row(
                                    children: [
                                      // Admin side
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'عدد الأدمن',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              children: [
                                                _tallyButton(
                                                  icon: Icons.remove,
                                                  color: Colors.redAccent,
                                                  onTap: () => context
                                                      .read<AdminCubit>()
                                                      .decrementAdminCount(
                                                          employeeId),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  '$adminCount',
                                                  style: TextStyle(
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                _tallyButton(
                                                  icon: Icons.add,
                                                  color: Colors.green,
                                                  onTap: () => context
                                                      .read<AdminCubit>()
                                                      .incrementAdminCount(
                                                          employeeId),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Divider
                                      Container(
                                        width: 1,
                                        height: 40.h,
                                        color: Colors.grey.shade300,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 12.w),
                                      ),
                                      // Employee side + match indicator
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'عدد الموظف',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$employeeCount',
                                                  style: TextStyle(
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 6.w),
                                                if (adminCount > 0)
                                                  Icon(
                                                    isMatch
                                                        ? Icons.check_circle
                                                        : Icons.warning_rounded,
                                                    color: isMatch
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    size: 20.sp,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('something went wrong'));
        },
      ),
    );
  }

  Widget _tallyButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(icon, size: 16.sp, color: color),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String employeeId,
    String? name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف موظف'),
        content: Text('هل أنت متأكد من حذف الموظف "${name ?? employeeId}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AdminCubit>().deleteEmployee(employeeId);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SlideInDown(
        delay: const Duration(milliseconds: 300),
        from: 8,
        child: Column(
          children: [
            const Text(
              'إجمالي دخل اليوم بالكامل',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '$total جنيه',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
