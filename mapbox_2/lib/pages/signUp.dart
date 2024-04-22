import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart'; // Import the flutter_pw_validator package

class signUpPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const signUpPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<signUpPage> createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _isPasswordValid = false; // Add this line to track password validity
  String _errorMessage = '';
  bool _showPassword = false;

  void togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
  void showPasswordRequirements() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Password Requirements"),
          content: const Text("Your password must be at least 8 characters long, include an uppercase letter, a number, and a special character."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> addUserDetails(String email, String firstName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'UserID': userId,
        'Email': email,
        'Name': firstName,
        'Registration Date': DateTime.now(),
      });
    } else {
      print('User is null - Failed to retrieve current user after sign up');
    }
  }



  Future<void> signUp() async {
    setState(() {
      _loading = true;
      _errorMessage = ''; // Clear any previous error message
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await addUserDetails(
        _emailController.text.trim(),
        _firstNameController.text,
      );
    } catch (error) {
      setState(() {
        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'email-already-in-use':
              _errorMessage = 'The email address is already in use.';
              break;
            case 'weak-password':
              _errorMessage = 'The password provided is too weak.';
              break;
            case 'invalid-email':
              _errorMessage = 'The email address is not valid.';
              break;
            case 'operation-not-allowed':
              _errorMessage = 'Email/password accounts not enabled.';
              break;
            case 'too-many-requests':
              _errorMessage = 'Too many requests. Try again later.';
              break;
            default:
              _errorMessage = 'An error occurred during sign up: ${error.message}';
          }
        } else {
          _errorMessage = error.toString();
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Register", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Flexible(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(hintText: 'First name'),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: togglePasswordVisibility,
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: FlutterPwValidator(
                  controller: _passwordController,
                  minLength: 8,
                  uppercaseCharCount: 1,
                  numericCharCount: 1,
                  specialCharCount: 1,
                  width: 400,
                  height: 150,
                  defaultColor: Colors.grey,
                  successColor: Colors.green,
                  failureColor: Colors.red,
                  onSuccess: () => setState(() => _isPasswordValid = true),
                  onFail: () => setState(() => _isPasswordValid = false),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreenAccent),
                  onPressed: (_loading || !_isPasswordValid) ? null : signUp,
                  child: _loading ? CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
                ),
              ),
              if (_errorMessage.isNotEmpty) Text(_errorMessage, style: TextStyle(color: Colors.red)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already a member?', style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.showLoginPage,
                    child: const Text('Sign In', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}