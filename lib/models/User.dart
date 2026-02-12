class User {
  
  String? name;
  String? email;
  String? profileImage;

  
  
  User({
    this.name,
    this.email,
    this.profileImage,
  });

  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }
}