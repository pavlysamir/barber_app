import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/core/theme/app_colors.dart';
import 'package:barber_app/features/admin/managers/admin_cubit.dart';
import 'package:barber_app/features/employee/data/models/withdrawal_model.dart';
import 'package:intl/intl.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeDetailsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  List<WithdrawalModel> _withdrawals = [];

  @override
  void initState() {
    super.initState();
    // Start listening to this employee's withdrawals
    context.read<AdminCubit>().listenToEmployeeWithdrawals(widget.employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          // Reset the cubit state to the daily report so the dashboard doesn't crash
          context.read<AdminCubit>().listenToDailyReport(DateTime.now());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('تفاصيل ${widget.employeeName}')),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminEmployeeWithdrawalsLoaded) {
                  setState(() {
                    _withdrawals = state.withdrawals;
                  });
                }
              },
            ),
          ],
          child: BlocBuilder<AdminCubit, AdminState>(
            // Re-build only on report state; withdrawals update via setState
            buildWhen: (_, state) =>
                state is AdminReportLoaded || state is AdminLoading,
            builder: (context, state) {
              if (state is AdminReportLoaded) {
                final transactions = state.transactions
                    .where((t) => t.employeeId == widget.employeeId)
                    .toList();
                final adminCount =
                    state.adminTallyCounts[widget.employeeId] ?? 0;
                final employeeCount = transactions.length;

                if (transactions.isEmpty && adminCount == 0) {
                  return const Center(child: Text('لا توجد معاملات اليوم'));
                }

                final grandTotal = transactions.fold<double>(
                  0,
                  (sum, t) =>
                      sum +
                      t.selectedServices
                          .fold<double>(0, (sSum, s) => sSum + s.price),
                );

                final totalWithdrawn =
                    _withdrawals.fold<double>(0, (sum, w) => sum + w.amount);
                final netAmount = grandTotal - totalWithdrawn;

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16.w),
                        children: [
                          // ── Summary Card ──────────────────────────────
                          _buildSummaryCard(
                            context,
                            grandTotal: grandTotal,
                            totalWithdrawn: totalWithdrawn,
                            netAmount: netAmount,
                            adminCount: adminCount,
                            employeeCount: employeeCount,
                          ),
                          SizedBox(height: 20.h),

                          // ── Withdrawals Section ───────────────────────
                          if (_withdrawals.isNotEmpty) ...[
                            Text(
                              'سجل السحوبات',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ..._withdrawals
                                .map((w) => _buildWithdrawalTile(w)),
                            SizedBox(height: 20.h),
                          ],

                          // ── Transactions Section ──────────────────────
                          Text(
                            'معاملات اليوم',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          ...transactions
                              .map((t) => _buildTransactionCard(t)),
                        ],
                      ),
                    ),

                    // ── Bottom Action Bar ─────────────────────────────
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
                      child: SizedBox(
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
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────

  Widget _buildSummaryCard(
    BuildContext context, {
    required double grandTotal,
    required double totalWithdrawn,
    required double netAmount,
    required int adminCount,
    required int employeeCount,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          // Count comparison
          if (adminCount > 0 || employeeCount > 0)
            _buildCountComparison(
              context,
              adminCount: adminCount,
              employeeCount: employeeCount,
            ),
          if (adminCount > 0 || employeeCount > 0)
            const Divider(color: Colors.white24, height: 24),

          // Amounts
          _summaryRow(
            label: 'إجمالي المحصّل (خدمات):',
            value: '${grandTotal.toStringAsFixed(2)} جنيه',
            valueColor: AppColors.gold,
          ),
          SizedBox(height: 8.h),
          _summaryRow(
            label: 'إجمالي المسحوب:',
            value: '${totalWithdrawn.toStringAsFixed(2)} جنيه',
            valueColor: Colors.orangeAccent,
          ),
          const Divider(color: Colors.white24, height: 20),
          _summaryRow(
            label: 'الصافي المتبقي:',
            value: '${netAmount.toStringAsFixed(2)} جنيه',
            valueColor: Colors.greenAccent,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required Color valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13.sp,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: bold ? 18.sp : 14.sp,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Withdrawal Tile ───────────────────────────────────────────────────────

  Widget _buildWithdrawalTile(WithdrawalModel w) {
    final time = DateFormat('hh:mm a').format(w.date);
    return Card(
      color: Colors.orange.shade50,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent,
          child: const Icon(Icons.account_balance_wallet,
              color: Colors.white, size: 18),
        ),
        title: Text(
          '${w.amount.toStringAsFixed(2)} جنيه',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: w.note.isNotEmpty ? Text(w.note) : null,
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
        ),
      ),
    );
  }

  // ── Transaction Card ──────────────────────────────────────────────────────

  Widget _buildTransactionCard(t) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
            const Divider(),
            ...t.selectedServices.map(
              (s) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic)),
                    Text('${p.price} جنيه',
                        style: const TextStyle(color: Colors.blueGrey)),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي (خدمات + منتجات)',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${t.totalPrice} جنيه',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 12.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── End Day Dialog ────────────────────────────────────────────────────────

  void _showEndDayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إنهاء اليوم'),
        content: const Text(
          'هل أنت متأكد من إنهاء اليوم لهذا الموظف؟ سيتم تصفية قائمة الزبائن الحالية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              context.read<AdminCubit>().closeEmployeeDay(
                    widget.employeeId,
                    DateTime.now(),
                  );
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  // ── Count comparison widget ───────────────────────────────────────────────

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
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _countColumn('عدد الأدمن', adminCount, Colors.white),
          Container(width: 1, height: 36.h, color: Colors.white24),
          _countColumn('عدد الموظف', employeeCount, Colors.white),
          Container(width: 1, height: 36.h, color: Colors.white24),
          _countLabel(diffText, color),
        ],
      ),
    );
  }

  Widget _countColumn(String label, int value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11.sp, color: Colors.white60)),
        SizedBox(height: 4.h),
        Text(
          '$value',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: valueColor),
        ),
      ],
    );
  }

  Widget _countLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 12.sp, fontWeight: FontWeight.bold, color: color),
    );
  }
}
