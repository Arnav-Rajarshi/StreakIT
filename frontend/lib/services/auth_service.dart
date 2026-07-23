import 'dart:convert';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/auth_models.dart';


 

class AuthService {

    Future<LoginResponse> login(LoginRequest request) async {

    final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      
      print(response.body);

      return LoginResponse.fromJson(
        jsonDecode(response.body),
      );
    }
     
    Future<LoginResponse> signup(UserCreate user) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/signup"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    return LoginResponse.fromJson(
      jsonDecode(response.body),
    );
  }

}

