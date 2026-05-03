import 'package:daily_record/core/models/login_request.dart';
import 'package:daily_record/core/models/login_response.dart';
import 'package:daily_record/core/models/logout_all_request.dart';
import 'package:daily_record/core/models/logout_request.dart';
import 'package:daily_record/core/models/logout_response.dart';
import 'package:daily_record/core/models/register_request.dart';
import 'package:daily_record/core/models/register_response.dart';

abstract class IAuthRepository {
  Future<LoginResponse> login(LoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LogoutResponse> logout(LogoutRequest request);
  Future<LogoutResponse> logoutAll(LogoutAllRequest request);
}
