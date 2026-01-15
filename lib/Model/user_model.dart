import '../core/api_exception.dart';

class UserModel {
  final String id;
  late final String name;
  final String email;
  late final String? gender;
  late final int? age;
  final String? profilePicture;

  final String? aiPersonalization;


  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.age,
    this.profilePicture,
    this.aiPersonalization
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw ApiException('Empty user data');
    }
    return UserModel(
      name:json['name'] as String,
      id: json['user_id'] as String,
      email: json['email'] as String,
      gender: json['gender'],
      age: json['age'],
      profilePicture: json['profile_picture'],
      aiPersonalization: json['ai_prefernce'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id':id,
      'name':name,
      'email': email,
      'gender': gender,
      'age': age,
      'profile_picture': profilePicture,
      'aiPersonalization':aiPersonalization
    };
  }
}
extension UserModelCopy on UserModel {
  UserModel copyWith({
    String? name,
    String? gender,
    int? age,
    String? aiPersonalization,
    String? profilePicture,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      aiPersonalization: aiPersonalization ?? this.aiPersonalization,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
