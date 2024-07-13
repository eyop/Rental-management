class UserModel {
  String? uid;
  String? contact;
  String? email;
  String? username;
  String? updatedAt;

  UserModel({
    this.uid,
    this.contact,
    this.email,
    this.username,
  });
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'contact': contact,
      'username': username,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> value) {
    return UserModel(
      uid: value["uid"],
      contact: value["contact"],
      email: value["email"],
      username: value['username'],
    );
  }
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: name ?? this.username,
      email: email ?? this.email,
      contact: phone ?? this.contact,
    );
  }
}
