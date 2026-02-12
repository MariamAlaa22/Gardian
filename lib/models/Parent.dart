import 'user.dart';

class Parent extends User {
  
  
  
  Parent({
    String? name,
    String? email,
    String? profileImage,
  }) : super(name: name, email: email, profileImage: profileImage);

  
  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
    );
  }

  
  @override
  Map<String, dynamic> toMap() {
    
    return super.toMap();
  }
}