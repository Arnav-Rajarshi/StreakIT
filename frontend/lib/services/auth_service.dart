import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/auth_models.dart';


final String baseUrl = 'http://127.0.0.1:8000';

class AuthService {

    Future<LoginResponse> login(LoginRequest request) async {

    final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return LoginResponse.fromJson(
        jsonDecode(response.body),
      );
    }
     
    Future<LoginResponse> signup(UserCreate user) async {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers:{
          "Content-Type": "application/json",
        },
        body:jsonEncode(user.toJson())
        );
      
      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return LoginResponse.fromJson(
        jsonDecode(response.body),
      );
    }

}

