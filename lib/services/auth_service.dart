import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // التعديل الأول: استخدم الطريقة الافتراضية للوصول للداتابيز
  // لا داعي لوضع الرابط يدوياً طالما ملف google-services.json موجود ومحدث
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    "users/parents",
  );

  Future<String?> signUp(String name, String email, String password) async {
    try {
      // 1. إنشاء الحساب (التطبيق سينتظر هذه الخطوة فقط)
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // 2. الحفظ في الداتابيز (بدون await) 🔥
        // حذفنا كلمة await واستخدمنا catchError للتعامل مع أي خطأ في الخلفية
        _dbRef
            .child(user.uid)
            .set({
              "name": name,
              "email": email,
              "role": "parent",
              "createdAt": ServerValue.timestamp,
            })
            .catchError((error) {
              // هذا الكود سيعمل في الخلفية إذا حدثت مشكلة في الداتابيز
              print("Background Database Error: $error");
            });

        // 3. إرجاع النجاح فوراً بمجرد انتهاء إنشاء الحساب!
        return "success";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
    return "An unknown error occurred";
  }

  // ميثود الـ login تظل كما هي عندك بدون تغيير
  Future<String?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await SharedPrefsUtils.setString("user_uid", result.user!.uid);
        return "success";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
    return "An error occurred";
  }
}
