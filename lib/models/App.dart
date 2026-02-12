import 'screen_lock.dart';

class App {
  
  String? appName;
  String? packageName;
  bool blocked;
  ScreenLock? screenLock;

  
  
  App({
    this.appName,
    this.packageName,
    this.blocked = false,
    this.screenLock,
  });

  
  factory App.fromMap(Map<String, dynamic> map) {
    return App(
      appName: map['appName'],
      packageName: map['packageName'],
      blocked: map['blocked'] ?? false,
      
      screenLock: map['screenLock'] != null 
          ? ScreenLock.fromMap(map['screenLock']) 
          : null,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'blocked': blocked,
      'screenLock': screenLock?.toMap(), 
    };
  }
}