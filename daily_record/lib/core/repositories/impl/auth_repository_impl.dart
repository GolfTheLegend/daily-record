import 'package:daily_record/core/models/login_request.dart';
import 'package:daily_record/core/models/login_response.dart';
import 'package:daily_record/core/models/logout_all_request.dart';
import 'package:daily_record/core/models/logout_request.dart';
import 'package:daily_record/core/models/logout_response.dart';
import 'package:daily_record/core/models/register_request.dart';
import 'package:daily_record/core/models/register_response.dart';
import 'package:daily_record/core/repositories/auth_repository.dart';
import 'package:daily_record/core/services/login_service.dart';
import 'package:daily_record/core/services/logout_service.dart';
import 'package:daily_record/core/services/register_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final LoginService _loginService;
  final RegisterService _registerService;
  final LogoutService _logoutService;

  AuthRepositoryImpl({
    LoginService? loginService,
    RegisterService? registerService,
    LogoutService? logoutService,
  })  : _loginService = loginService ?? LoginService(),
        _registerService = registerService ?? RegisterService(),
        _logoutService = logoutService ?? LogoutService();

  @override
  Future<LoginResponse> login(LoginRequest request) {
    return _loginService.login(request);
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) {
    return _registerService.register(request);
  }

  @override
  Future<LogoutResponse> logout(LogoutRequest request) {
    return _logoutService.logout(request);
  }

  @override
  Future<LogoutResponse> logoutAll(LogoutAllRequest request) {
    return _logoutService.logoutAll(request);
  }
}
