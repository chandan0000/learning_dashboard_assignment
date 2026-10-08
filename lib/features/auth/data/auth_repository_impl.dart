import 'package:learning_dashboard/core/storage/token_storage.dart';
import 'package:learning_dashboard/features/auth/data/auth_api.dart';
import 'package:learning_dashboard/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._api,
    required this._tokenStorage,
  });

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  @override
  Future<void> login({required String email, required String password}) async {
    final token = await _api.login(email: email, password: password);
    await _tokenStorage.saveToken(token);
  }

  @override
  Future<void> logout() => _tokenStorage.clearToken();

  @override
  Future<bool> isLoggedIn() async => (await _tokenStorage.readToken()) != null;
}
