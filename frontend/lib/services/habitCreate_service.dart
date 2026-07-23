import 'dart:convert';

import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;

import '../models/habit_create_models.dart';

class HabitService {

  static Future<void> createHabit(
  String uid,
  HabitCreateRequest request,
  ) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/habits/$uid"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(response.body);
    }
  }
}