import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/result/result.dart';
import '../models/auth_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Result<AuthModel>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return Result.success(AuthModel.fromJson(response.data));
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Erro ao fazer login',
        exception: e,
      ));
    }
  }

  Future<Result<AuthModel>> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return Result.success(AuthModel.fromJson(response.data));
    } on DioException catch (e) {
      return Result.failure(Failure(
        e.response?.data?['message'] ?? 'Erro ao criar conta',
        exception: e,
      ));
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.failure(Failure('Erro ao fazer logout', exception: e));
    }
  }
}