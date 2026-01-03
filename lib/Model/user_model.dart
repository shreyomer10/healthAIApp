import '../core/api_exception.dart';

class UserModel {
  final String id;
  final String email;
  final String? gender;
  final int? age;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.email,
    this.gender,
    this.age,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw ApiException('Empty user data');
    }
    return UserModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      gender: json['gender'],
      age: json['age'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id':id,
      'email': email,
      'gender': gender,
      'age': age,
      'profile_picture': profilePicture,
    };
  }
}
