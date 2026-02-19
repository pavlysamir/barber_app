import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barber_app/core/utils/widgets.dart';
import 'package:barber_app/features/auth/managers/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تسجيل الدخول',
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 48.h),
              CustomTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'كلمة المرور',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),
              SizedBox(height: 32.h),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomButton(
                    text: 'دخول',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      context.read<AuthCubit>().login(
                            _emailController.text,
                            _passwordController.text,
                          );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
