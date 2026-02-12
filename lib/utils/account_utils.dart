import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AccountUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");

  
  static Future<void> changePassword(BuildContext context, String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Updated Successfully")),
      );
      logout(context); 
    } catch (e) {
      print("Error changing password: $e");
    }
  }

  
  static Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    
    
  }

  
  static Future<void> deleteAccount(BuildContext context, String? password) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String providerId = user.providerData[0].providerId;

    
    await _deleteAccountData(user, providerId, password, context);
  }

  static Future<void> _deleteAccountData(User user, String providerId, String? password, BuildContext context) async {
    
    final List<String> paths = ["parents", "childs"];
    
    for (String path in paths) {
      DataSnapshot snapshot = await _dbRef.child(path).child(user.uid).get();
      if (snapshot.exists) {
        
        String? imgUrl = snapshot.child("profileImage").value as String?;
        if (imgUrl != null && imgUrl.contains("firebasestorage")) {
          await FirebaseStorage.instance.refFromURL(imgUrl).delete();
        }
        
        await _dbRef.child(path).child(user.uid).remove();
      }
    }
    
    
    await _deleteUserFromAuth(user, providerId, password, context);
  }

  static Future<void> _deleteUserFromAuth(User user, String providerId, String? password, BuildContext context) async {
    try {
      AuthCredential? credential;
      if (providerId == "google.com") {
        
        
      } else if (password != null) {
        credential = EmailAuthProvider.credential(email: user.email!, password: password);
      }

      if (credential != null) {
        await user.reauthenticateWithCredential(credential);
      }
      
      await user.delete();
      logout(context);
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}