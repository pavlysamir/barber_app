import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/features/auth/data/repos/auth_repo.dart';
import 'package:barber_app/features/employee/data/repos/employee_repo.dart';
import 'package:barber_app/features/admin/data/repos/admin_repo.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Firebase Services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(auth: getIt(), firestore: getIt()),
  );
  getIt.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(firestore: getIt()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(firestore: getIt(), auth: getIt()),
  );
}
