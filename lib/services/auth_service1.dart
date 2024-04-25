// auth_service1.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class AuthService1 {
  Future<String?> signInWithEmailAndPassword(String email,
      String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user?.uid;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
