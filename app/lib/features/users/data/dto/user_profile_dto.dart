class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.email,
    required this.name,
    required this.isOnboardingCompleted,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
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

class UpdateProfileRequest {
  const UpdateProfileRequest({this.name});

  final String? name;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
      };
}
