import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/auth_models.dart';


final String baseUrl = 'http://127.0.0.1:8000';

class AuthService {

    Future<void> login(LoginRequest request) async {
      
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers:{
          "Content-Type": "application/json",
        },
        body:jsonEncode(request.toJson())
        );

    print(response.statusCode);
    print(response.body);
    }
     
    Future<void> signup(UserCreate user) async {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers:{
          "Content-Type": "application/json",
        },
        body:jsonEncode(user.toJson())
        );

    print(response.statusCode);
    print(response.body);
    }

}

