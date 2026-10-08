import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/core/network/network_info.dart';

abstract interface class AuthApi {
  Future<String> login({required String email, required String password});
}

class MockAuthApi implements AuthApi {
  MockAuthApi({
    required this._networkInfo,
    this.latency = const Duration(seconds: 1),
  });

  static const demoEmail = 'student@example.com';
  static const demoPassword = 'password123';

  final NetworkInfo _networkInfo;
  final Duration latency;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
    await Future<void>.delayed(latency);

    final isValid =
        email.trim().toLowerCase() == demoEmail && password == demoPassword;
    if (!isValid) throw const InvalidCredentialsException();

    return 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
  }
}
