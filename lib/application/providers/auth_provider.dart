import 'package:aplicacion_ventas/core/utils/result.dart';
import 'package:aplicacion_ventas/data/datasources/remote/auth_remote_datasource.dart';
import 'package:aplicacion_ventas/data/repositories/auth_repository_impl.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/domain/usecases/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for the authentication flow.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage, bool resetError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod notifier that coordinates login actions.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._loginUseCase) : super(const AuthState());

  final LoginUseCase _loginUseCase;

  Future<void> login(String rut, String password) async {
    state = state.copyWith(isLoading: true, resetError: true);
    final result = await _loginUseCase(rut, password);
    state = result.fold(
      failure: (error) => AuthState(isLoading: false, errorMessage: error.message),
      success: (user) => AuthState(user: user, isLoading: false),
    );
  }
}

final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDataSource());
final authRepositoryProvider = Provider(
  (ref) => AuthRepositoryImpl(remoteDataSource: ref.watch(authRemoteDataSourceProvider)),
);
final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(loginUseCaseProvider)),
);
