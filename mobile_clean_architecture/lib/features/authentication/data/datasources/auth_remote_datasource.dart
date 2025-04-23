import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Interface for authentication remote data source
abstract class AuthRemoteDataSource {
  /// Sign in a user with email and password
  Future<UserModel> signIn(String email, String password);

  /// Register a new user with name, email, and password
  Future<UserModel> register(String name, String email, String password);
}

/// Implementation of authentication remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email, // OAuth2 expects 'username' instead of 'email'
          'password': password,
        },
      ).timeout(Duration(seconds: ApiConstants.timeoutDuration));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(
          message: 'Failed to login: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await client
          .post(
            Uri.parse(
              '${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: ApiConstants.timeoutDuration));

      if (response.statusCode == 201) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException(
          message: 'Failed to register: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
