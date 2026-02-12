import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Validators {
  
  
  static bool isValidEmail(String email) {
    final emailPattern = RegExp(r"^[a-zA-Z0-9._-]+@[a-z]+\.[a-z]+");
    if (email.isEmpty) return false;
    return emailPattern.hasMatch(email.trim());
  }

  
  static bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  
  static bool isValidHours(String hours) {
    int? h = int.tryParse(hours);
    return h != null && h >= 0 && h <= 23;
  }

  
  static bool isValidMinutes(String minutes) {
    int? m = int.tryParse(minutes);
    return m != null && m >= 0 && m <= 59;
  }

  
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length <= 15;
  }

  
  static bool isVerified(User? user) {
    return user?.emailVerified ?? false;
  }

  
  static Future<bool> isInternetAvailable() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) || 
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  
  static Future<bool> isLocationOn() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}