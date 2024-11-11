import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'user_profile.dart';

class ApiClientService {
  final HttpClient client = HttpClient();
  final String _host = 'api.example.com';
  final int _port = 443;

  Future<UserProfile> getUserProfile() async {
    try {
      final request = await client.get(_host, _port, '/user');
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        return UserProfile.fromJson(jsonDecode(stringData));
      } else {
        throw const HttpException("Invalid response");
      }
    } finally {
      client.close();
    }
  }
}

class UserProfileRepository {
  final ApiClientService _apiClientService = ApiClientService();

  Future<UserProfile> getUserProfile() async {
    return await _apiClientService.getUserProfile();
  }
}

class UserProfileViewModel extends ChangeNotifier {
  final UserProfileRepository userProfileRepository = UserProfileRepository();
  UserProfile? userProfile;

  Future<void> load() async {
    try {
      userProfile = await userProfileRepository.getUserProfile();
      notifyListeners();
    } on Exception catch (exception) {
      // handle exception
    }
  }
}
