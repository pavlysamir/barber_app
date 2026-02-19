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
    // context.read<AdminCubit>().loadEmployees();
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
          // Only rebuild UI for these states, ignore the rest
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.employeeMap.length,
                      itemBuilder: (context, index) {
                        final employeeId = state.employeeMap.keys.elementAt(
                          index,
                        );
                        final employee = state.employeeMap[employeeId]!;
                        final total = state.employeeTotals[employeeId] ?? 0.0;
                        final customerCount =
                            state.employeeCustomerCounts[employeeId] ?? 0;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          child: ListTile(
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
                            leading: CircleAvatar(
                              child: Text(
                                employee.name.isNotEmpty
                                    ? employee.name.substring(0, 1)
                                    : 'M',
                              ),
                            ),
                            title: Text(employee.name),
                            subtitle: Text('عدد الزبائن: $customerCount'),
                            trailing: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '$total جنيه',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _showDeleteConfirmation(
                                    context,
                                    employeeId,
                                    employee.name,
                                  ),
                                ),
                              ],
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
          return Center(child: Text('something went wrong'));
        },
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
