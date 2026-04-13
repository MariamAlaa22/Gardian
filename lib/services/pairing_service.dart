import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gardians/constants/pairing_constants.dart';

class PairingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final Random _random = Random();

  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Future<String> createParentCode() async {
    final parent = await ensureSignedIn();
    final code = _generateNumericCode(pairingCodeLength);
    await _db.child('pairing_codes').child(code).set({
      'parentUid': parent.uid,
      'createdAt': ServerValue.timestamp,
      'used': false,
      'childUid': '',
    });
    return code;
  }

  Future<String> linkChildWithCode(String code) async {
    final child = await ensureSignedIn();
    final normalized = code.trim();
    if (normalized.length != pairingCodeLength) {
      throw Exception('Code must be exactly $pairingCodeLength digits.');
    }

    final codeRef = _db.child('pairing_codes').child(normalized);
    final codeSnap = await codeRef.get();
    if (!codeSnap.exists) throw Exception('Invalid code.');

    final data = Map<String, dynamic>.from(codeSnap.value as Map);
    if (data['used'] == true) throw Exception('Code already used.');
    final parentUid = (data['parentUid'] ?? '').toString();
    if (parentUid.isEmpty) throw Exception('Parent data missing.');

    await _db.child('links/parent_children/$parentUid/${child.uid}').set(true);
    await _db.child('links/child_parent/${child.uid}').set(parentUid);
    await codeRef.update({
      'used': true,
      'childUid': child.uid,
      'usedAt': ServerValue.timestamp,
    });
    return parentUid;
  }

  Future<String?> checkParentLinkedChild(String code) async {
    final normalized = code.trim();
    final snap = await _db.child('pairing_codes/$normalized/childUid').get();
    if (!snap.exists) return null;
    final value = (snap.value ?? '').toString();
    return value.isEmpty ? null : value;
  }

  String _generateNumericCode(int length) {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(_random.nextInt(10));
    }
    return buffer.toString();
  }
}
