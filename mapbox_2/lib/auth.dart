import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/pages/signUp.dart';
import '/pages/login_page.dart';


class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool _isLogin = true; // Changed to true for default login screen

  void toggleScreens(){
    setState(() {
      _isLogin = !_isLogin;
    });

  }
  bool _loading = false;
  String _errorMessage = ''; // Track error message

  @override
  Widget build(BuildContext context) {
    if (_isLogin) {
      return LoginPage(showSignUpPage: toggleScreens);
    }else{
      return signUpPage(showLoginPage: toggleScreens);
    }

  }





  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> registerWithEmailandPassword(String email, String password) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithEmailandPassword(String email, String password) async{
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
  }
}