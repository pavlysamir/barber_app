import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/features/admin/managers/admin_cubit.dart';
import 'package:intl/intl.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeDetailsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل $employeeName')),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminReportLoaded) {
            final transactions = state.transactions
                .where((t) => t.employeeId == employeeId)
                .toList();
            final adminCount = state.adminTallyCounts[employeeId] ?? 0;
            final employeeCount = transactions.length;

            if (transactions.isEmpty && adminCount == 0) {
              return const Center(child: Text('لا توجد معاملات اليوم'));
            }

            final grandTotal = transactions.fold<double>(
              0,
              (sum, t) =>
                  sum +
                  t.selectedServices.fold<double>(0, (sSum, s) => sSum + s.price),
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      final time = DateFormat('hh:mm a').format(t.date);
                      final date = DateFormat('yyyy/MM/dd').format(t.date);

                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    t.customerName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Text(
                                    '$time - $date',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ...t.selectedServices.map(
                                (s) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(s.name),
                                      Text('${s.price} جنيه'),
                                    ],
                                  ),
                                ),
                              ),
                              if (t.selectedProducts.isNotEmpty)
                                const Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ...t.selectedProducts.map(
                                (p) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        '${p.price} جنيه',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'إجمالي (خدمات + منتجات)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${t.totalPrice} جنيه',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Admin vs Employee comparison
                      if (adminCount > 0 || employeeCount > 0)
                        _buildCountComparison(
                          context,
                          adminCount: adminCount,
                          employeeCount: employeeCount,
                        ),
                      if (adminCount > 0 || employeeCount > 0)
                        SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي مستحقات اليوم:',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${grandTotal.toStringAsFixed(2)} جنيه',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () => _showEndDayDialog(context),
                          child: const Text('إنهاء المعاملات وتصفية الحساب'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showEndDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إنهاء اليوم'),
        content: const Text(
          'هل أنت متأكد من إنهاء اليوم لهذا الموظف؟ سيتم تصفية قائمة الزبائن الحالية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              context.read<AdminCubit>().closeEmployeeDay(
                employeeId,
                DateTime.now(),
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Widget _buildCountComparison(
    BuildContext context, {
    required int adminCount,
    required int employeeCount,
  }) {
    final diff = adminCount - employeeCount;
    final isMatch = diff == 0;
    final color = isMatch ? Colors.green : Colors.redAccent;
    final diffText = diff == 0
        ? 'مطابق ✅'
        : diff > 0
            ? 'فرق +$diff ⚠️'
            : 'فرق $diff ⚠️';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _countColumn('عدد الأدمن', adminCount, Colors.black87),
          Container(width: 1, height: 36.h, color: Colors.grey.shade300),
          _countColumn('عدد الموظف', employeeCount, Colors.black87),
          Container(width: 1, height: 36.h, color: Colors.grey.shade300),
          _countLabel(diffText, color),
        ],
      ),
    );
  }

  Widget _countColumn(String label, int value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
        SizedBox(height: 4.h),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _countLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
