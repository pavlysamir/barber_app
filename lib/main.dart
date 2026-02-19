import 'package:barber_app/core/cashe/cache_helper.dart';
import 'package:barber_app/core/di/service_locator.dart';
import 'package:barber_app/core/helper/simple_bloc_observer.dart';
import 'package:barber_app/core/theme/app_theme.dart';
import 'package:barber_app/features/admin/managers/admin_cubit.dart';
import 'package:barber_app/features/admin/presentation/screens/dashboard_screen.dart';
import 'package:barber_app/features/auth/managers/auth_cubit.dart';
import 'package:barber_app/features/auth/presentation/screens/login_screen.dart';
import 'package:barber_app/features/employee/managers/employee_cubit.dart';
import 'package:barber_app/features/employee/presentation/screens/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheHelper.init();
  Bloc.observer = SimpleBlocObserver();
  await setupServiceLocator();
  runApp(const BarberApp());
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthCubit(getIt())..checkAuth()),
            BlocProvider(create: (context) => EmployeeCubit(getIt())),
            BlocProvider(create: (context) => AdminCubit(getIt())),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: const Locale('ar'),

            supportedLocales: const [Locale('ar'), Locale('en')],

            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            localeResolutionCallback: (locale, supportedLocales) {
              return const Locale('ar');
            },
            home: const RootNavigator(),
          ),
        );
      },
    );
  }
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return state.user.role.name == 'admin'
              ? const AdminDashboardScreen()
              : const EmployeeDashboardScreen();
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
