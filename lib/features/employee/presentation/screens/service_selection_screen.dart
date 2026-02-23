import 'package:barber_app/features/employee/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/features/employee/managers/employee_cubit.dart';
import 'package:barber_app/features/employee/data/models/service_model.dart';
import 'package:barber_app/features/admin/data/models/product_model.dart';
import 'package:barber_app/features/employee/data/models/transaction_model.dart';
import 'package:barber_app/features/auth/managers/auth_cubit.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final List<ServiceModel> _selectedServices = [];
  final List<ProductModel> _selectedProducts = [];
  final _customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeCubit>().loadServicesAndProducts();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة معاملة'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeDashboardScreen(),
                ),
              );
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'الخدمات', icon: Icon(Icons.cut)),
              Tab(text: 'المنتجات', icon: Icon(Icons.shopping_bag)),
            ],
          ),
        ),
        body: BlocConsumer<EmployeeCubit, EmployeeState>(
          listener: (context, state) {
            if (state is EmployeeTransactionSuccess) {
              Navigator.pushReplacement(
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
                    child: TabBarView(
                      children: [
                        _buildServicesGrid(state.services),
                        _buildProductsGrid(state.products),
                      ],
                    ),
                  ),
                  _buildBottomBar(),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildServicesGrid(List<ServiceModel> services) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = _selectedServices.contains(service);
        return _buildSelectionItem(
          icon: Icons.cut,
          title: service.name,
          price: service.price,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              isSelected
                  ? _selectedServices.remove(service)
                  : _selectedServices.add(service);
            });
          },
        );
      },
    );
  }

  Widget _buildProductsGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isSelected = _selectedProducts.contains(product);
        final isOutOfStock = product.count <= 0;

        return _buildSelectionItem(
          icon: Icons.shopping_bag,
          title: product.name,
          price: product.price,
          isSelected: isSelected,
          isOutOfStock: isOutOfStock,
          onTap: isOutOfStock
              ? null
              : () {
                  setState(() {
                    isSelected
                        ? _selectedProducts.remove(product)
                        : _selectedProducts.add(product);
                  });
                },
          subtitle: 'متوفر: ${product.count}',
        );
      },
    );
  }

  Widget _buildSelectionItem({
    required IconData icon,
    required String title,
    required double price,
    required bool isSelected,
    bool isOutOfStock = false,
    required VoidCallback? onTap,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : isOutOfStock
                  ? Colors.grey.shade100
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isOutOfStock ? Colors.grey : null),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : (isOutOfStock ? Colors.grey : null),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$price جنيه',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isSelected ? Colors.white60 : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final servicesTotal =
        _selectedServices.fold<double>(0, (sum, s) => sum + s.price);
    final productsTotal =
        _selectedProducts.fold<double>(0, (sum, p) => sum + p.price);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedProducts.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('مبيعات منتجات (أدمن فقط):',
                      style: TextStyle(color: Colors.grey)),
                  Text('$productsTotal جنيه',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إجمالي الخدمات'),
                    Text(
                      '$servicesTotal جنيه',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: (_selectedServices.isEmpty &&
                        _selectedProducts.isEmpty)
                    ? null
                    : _submit,
                child: const Text('حفظ المعاملة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final user = (context.read<AuthCubit>().state as AuthAuthenticated).user;
    final servicesTotal =
        _selectedServices.fold<double>(0, (sum, s) => sum + s.price);

    final transaction = TransactionModel(
      id: '',
      employeeId: user.id,
      customerName: _customerNameController.text.isEmpty
          ? 'زبون'
          : _customerNameController.text,
      selectedServices: _selectedServices,
      selectedProducts: _selectedProducts,
      totalPrice: servicesTotal,
      date: DateTime.now(),
    );
    context.read<EmployeeCubit>().submitTransaction(transaction);
  }
}
