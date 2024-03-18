import 'package:firebase_auth/firebase_auth.dart';

class Auth{
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> registerWithEmailandPassword(String email, String password) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithEmailandPassword(String email, String password) async{
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
  }
}