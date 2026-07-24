import 'dart:convert';

import 'package:frontend/config.dart';
import 'package:frontend/models/dashboard_models.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  Future<DashboardPageModel> getDashboard(String uid) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard?uid=$uid'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load dashboard.\n'
        'Status Code: ${response.statusCode}\n'
        'Body: ${response.body}',
      );
    }

    return DashboardPageModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
