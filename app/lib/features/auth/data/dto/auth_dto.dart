class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
      };
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.isOnboardingCompleted,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        isOnboardingCompleted: json['is_onboarding_completed'] as bool,
      );

  final String id;
  final String email;
  final String name;
  final bool isOnboardingCompleted;
}

class RegisterResponse {
  const RegisterResponse({required this.accessToken});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(accessToken: json['access_token'] as String);

  final String accessToken;
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.isOnboardingCompleted,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        isOnboardingCompleted: json['is_onboarding_completed'] as bool,
      );

  final String accessToken;
  final bool isOnboardingCompleted;
}
