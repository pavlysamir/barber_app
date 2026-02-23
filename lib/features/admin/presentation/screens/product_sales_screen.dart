import 'package:barber_app/features/admin/managers/admin_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ProductSalesScreen extends StatelessWidget {
  const ProductSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مبيعات المنتجات'),
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminReportLoaded) {
            final transactionsWithProducts = state.transactions
                .where((t) => t.selectedProducts.isNotEmpty)
                .toList();

            if (transactionsWithProducts.isEmpty) {
              return const Center(child: Text('لا توجد مبيعات منتجات اليوم'));
            }

            return Column(
              children: [
                _buildProductSummaryHeader(state.productTotal),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: transactionsWithProducts.length,
                    itemBuilder: (context, index) {
                      final t = transactionsWithProducts[index];
                      final employee = state.employeeMap[t.employeeId];
                      final time = DateFormat('hh:mm a').format(t.date);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'بواسطة: ${employee?.name ?? 'موظف غريب'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ...t.selectedProducts.map((p) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(p.name),
                                        Text('${p.price} جنيه'),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
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

  Widget _buildProductSummaryHeader(double total) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'إجمالي مبيعات المنتجات اليوم',
            style: TextStyle(color: Colors.blueGrey),
          ),
          SizedBox(height: 4.h),
          Text(
            '${total.toStringAsFixed(2)} جنيه',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}
