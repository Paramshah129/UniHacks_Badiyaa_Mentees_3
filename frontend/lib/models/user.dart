class UserModel {
  final String uid; // Firebase UID
  final String fullName;
  final String nickname;
  final String email;
  final String? photoUrl;
  final String? token;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.nickname,
    required this.email,
    this.photoUrl,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      fullName: json['fullName'],
      nickname: json['nickname'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'photoUrl': photoUrl,
      'token': token,
    };
  }
}