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
  final String username;
  final String email;
  final String password;

  UserCreate({
    required this.username,
    required this.email,
    required this.password
});

  Map<String,dynamic> toJson() {
    return {
      username:  username,
      email:  email,
      password: password
    };
  }
}