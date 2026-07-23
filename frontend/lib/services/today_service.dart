import 'dart:convert';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import '../models/today_models.dart';

class TodayService {

  Future<List<TodayHabit>> getTodayHabits(String uid) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/today?uid=$uid"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load habits.\n"
        "Status Code: ${response.statusCode}\n"
        "Body: ${response.body}",
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((json) => TodayHabit.fromJson(json))
        .toList();
  }

  Future<void> logHabit(HabitLogRequest request) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/habit-log"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to log habit");
    }
  }
}