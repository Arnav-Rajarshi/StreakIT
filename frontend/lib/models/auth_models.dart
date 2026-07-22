// API Response

// Login
class LoginRequest {
  final String userDetails; // username OR email
  final String password;

  LoginRequest({
    required this.userDetails,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_details": userDetails,
      "password": password,
    };
  }
}

// UserCreate
class UserCreate {
  final String user_name;
  final String email;
  final String password;

  UserCreate({
    required this.user_name,
    required this.email,
    required this.password
});

  Map<String,dynamic> toJson() {
    return {
      "user_name":  user_name,
      "email":  email,
      "password": password
    };
  }
}


class LoginResponse {
  final String message;
  final String uid;

  LoginResponse({
    required this.message,
    required this.uid,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json["message"],
      uid: json["uid"],
    );
  }
}