import 'package:barber_app/core/cashe/cache_helper.dart';
import 'package:barber_app/core/cashe/cashe_constance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:barber_app/features/auth/data/models/user_model.dart';
import 'package:barber_app/features/auth/data/repos/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      if (user != null) {
        await CacheHelper.set(key: CacheConstants.userId, value: user.id);
        await CacheHelper.set(key: CacheConstants.firstName, value: user.name);

        emit(AuthAuthenticated(user));
      } else {
        emit(
          const AuthError(
            'Login failed: User not found or incorrect credentials',
          ),
        );
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }


  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthLogout());
  }
}
