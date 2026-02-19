import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_app/features/auth/data/models/user_model.dart';
import 'package:barber_app/core/utils/constants.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({required this.auth, required this.firestore});

  @override
  Future<UserModel?> login(String email, String password) async {
    final userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null) {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    }
    return null;
  }

  @override
  Future<void> logout() => auth.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    }
    return null;
  }
}
