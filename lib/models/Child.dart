import 'user.dart';
import 'app.dart';
import 'contact.dart';
import 'location.dart';
import 'message.dart';
import 'call.dart';
import 'screen_lock.dart';

class Child extends User {
  
  String? parentEmail;
  List<App> apps = []; 
  List<Contact> contacts = []; 
  Location? location;
  Map<String, Message> messages = {}; 
  Map<String, Call> calls = {};
  ScreenLock? screenLock;
  bool appDeleted = false;

  
  Child({
    String? name,
    String? email,
    String? profileImage,
    this.parentEmail,
    this.location,
    this.screenLock,
    this.appDeleted = false,
    List<App>? apps,
    List<Contact>? contacts,
    Map<String, Message>? messages,
    Map<String, Call>? calls,
  }) : super(name: name, email: email, profileImage: profileImage) {
    
    this.apps = apps ?? [];
    this.contacts = contacts ?? [];
    this.messages = messages ?? {};
    this.calls = calls ?? {};
  }

  
  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      parentEmail: map['parentEmail'],
      appDeleted: map['appDeleted'] ?? false,
      
    );
  }

  
  @override
  Map<String, dynamic> toMap() {
    
    Map<String, dynamic> userMap = super.toMap();
    userMap.addAll({
      'parentEmail': parentEmail,
      'appDeleted': appDeleted,
      
    });
    return userMap;
  }
}