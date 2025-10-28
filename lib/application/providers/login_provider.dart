import 'package:aplicacion_ventas/application/services/login_service.dart';
import 'package:aplicacion_ventas/application/services/sync_service.dart';
import 'package:aplicacion_ventas/data/datasources/remote/sync_remote_datasource.dart';
import 'package:aplicacion_ventas/domain/entities/user.dart';
import 'package:aplicacion_ventas/utils/rut_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginServiceProvider = Provider<LoginService>((ref) {
  return LoginService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    remoteDataSource: SyncRemoteDataSource(),
    loginService: ref.watch(loginServiceProvider),
  );
});

final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(
    loginService: ref.watch(loginServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

/// State representation for the authentication and synchronization flow.
class LoginState {
  const LoginState({
    this.user,
    this.isLoggingIn = false,
    this.isSyncing = false,
    this.isDownloading = false,
    this.errorMessage,
    this.infoMessage,
    this.databasePath,
    this.isOffline = false,
  });

  final User? user;
  final bool isLoggingIn;
  final bool isSyncing;
  final bool isDownloading;
  final String? errorMessage;
  final String? infoMessage;
  final String? databasePath;
  final bool isOffline;

  LoginState copyWith({
    User? user,
    bool? isLoggingIn,
    bool? isSyncing,
    bool? isDownloading,
    String? errorMessage,
    String? infoMessage,
    String? databasePath,
    bool? isOffline,
    bool resetMessages = false,
  }) {
    return LoginState(
      user: user ?? this.user,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      isSyncing: isSyncing ?? this.isSyncing,
      isDownloading: isDownloading ?? this.isDownloading,
      errorMessage: resetMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: resetMessages ? null : (infoMessage ?? this.infoMessage),
      databasePath: databasePath ?? this.databasePath,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// Riverpod notifier that coordinates login and sync actions.
class LoginController extends StateNotifier<LoginState> {
  LoginController({required LoginService loginService, required SyncService syncService})
      : _loginService = loginService,
        _syncService = syncService,
        super(const LoginState());

  final LoginService _loginService;
  final SyncService _syncService;

  Future<bool> login(String rut, String password) async {
    final normalizedRut = RutUtils.toDatabaseFormat(rut);
    state = state.copyWith(isLoggingIn: true, resetMessages: true);
    final result = await _loginService.authenticate(rut: normalizedRut, password: password);
    var wasSuccessful = false;
    state = result.fold(
      failure: (failure) => state.copyWith(
        isLoggingIn: false,
        errorMessage: failure.message,
        isOffline: false,
      ),
      success: (data) => state.copyWith(
        user: data.user,
        isLoggingIn: false,
        databasePath: data.databaseAssetPath,
        isOffline: data.isOfflineMode,
        infoMessage: data.isOfflineMode
            ? 'Sesión iniciada en modo offline'
            : 'Sesión iniciada correctamente',
      ),
    );
    wasSuccessful = result.isSuccess;
    return wasSuccessful;
  }

  Future<bool> synchronizeSales(String rut) async {
    final normalizedRut = RutUtils.toDatabaseFormat(rut);
    state = state.copyWith(isSyncing: true, resetMessages: true);
    final result = await _syncService.syncLocalSales(rut: normalizedRut);
    var wasSuccessful = false;
    state = result.fold(
      failure: (failure) => state.copyWith(isSyncing: false, errorMessage: failure.message),
      success: (_) {
        wasSuccessful = true;
        return state.copyWith(
          isSyncing: false,
          infoMessage: 'Ventas sincronizadas correctamente',
        );
      },
    );
    return wasSuccessful;
  }

  Future<void> logout({bool clearPersistedCredentials = false}) async {
    await _loginService.logout(
      clearPersistedCredentials: clearPersistedCredentials,
    );
    state = const LoginState();
  }

  Future<bool> downloadData(String rut) async {
    final normalizedRut = RutUtils.toDatabaseFormat(rut);
    state = state.copyWith(isDownloading: true, resetMessages: true);
    final result = await _syncService.downloadLatestData(rut: normalizedRut);
    var wasSuccessful = false;
    state = result.fold(
      failure: (failure) => state.copyWith(isDownloading: false, errorMessage: failure.message),
      success: (_) {
        wasSuccessful = true;
        return state.copyWith(
          isDownloading: false,
          infoMessage: 'Datos descargados correctamente',
        );
      },
    );
    return wasSuccessful;
  }
}
