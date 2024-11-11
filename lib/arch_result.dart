import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'result.dart';
import 'user_profile.dart';

class ApiClientService {
  final HttpClient client = HttpClient();
  final String _host = 'api.example.com';
  final int _port = 443;

  Future<Result<UserProfile>> getUserProfile() async {
    try {
      final request = await client.get(_host, _port, '/user');
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        return Result.ok(UserProfile.fromJson(jsonDecode(stringData)));
      } else {
        throw Result.error(const HttpException("Invalid response"));
      }
    } on Exception catch (exception) {
      return Result.error(exception);
    } finally {
      client.close();
    }
  }
}

class DatabaseService {
  Future<Result<UserProfile>> createTemporaryUser() async {
    return Result.ok(UserProfile(name: 'Temp', email: 'temp@example.com'));
  }
}

class UserProfileRepository {
  final ApiClientService _apiClientService = ApiClientService();
  final DatabaseService _databaseService = DatabaseService();

  Future<Result<UserProfile>> getUserProfile() async {
    return await _apiClientService.getUserProfile();
  }

  Future<Result<UserProfile>> getUserProfile2() async {
    var result = await _apiClientService.getUserProfile();
    if (result is Ok<UserProfile>) {
      return result;
    }

    result = await _databaseService.createTemporaryUser();
    if (result is Ok<UserProfile>) {
      return result;
    }

    return Result.error(Exception('Failed to get user profile'));
  }
}

class UserProfileViewModel extends ChangeNotifier {
  final UserProfileRepository userProfileRepository = UserProfileRepository();
  UserProfile? userProfile;

  Future<void> load() async {
    final result = await userProfileRepository.getUserProfile();
    switch (result) {
      case Ok<UserProfile>():
        userProfile = result.value;
      case Error<UserProfile>():
      // handle error
    }
    notifyListeners();
  }
}
