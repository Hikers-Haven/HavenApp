import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  String _errorMessage = '';

  void showPasswordRequirements() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Password Requirements"),
          content: const Text("Your password must be at least 8 characters long, include an uppercase letter, a number, and a special character."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
  Future<void> signUp() async {
    setState(() {
      _loading = true;
      _errorMessage = ''; // Clear any previous error message
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text.trim(),
      );

      await addUserDetails(
        _emailController.text,
        _firstNameController.text,
      );
    } catch (error) {
      setState(() {
        if (error is FirebaseAuthException) {
          // Firebase Authentication error handling
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
            default:
              _errorMessage = 'An error occurred during sign up.';
          }
        } else {
          // Other errors
          _errorMessage = error.toString();
        }
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
      // Add the biking_sessions subcollection
      await FirebaseFirestore.instance.collection('users').doc(userId)
          .collection('biking_sessions').doc().set({
        'session': 'dummy_value', // initial test value
      });
      // add personal_best subcollection
      await FirebaseFirestore.instance.collection('users').doc(userId)
          .collection('personal_best').doc().set({
        'fastest_speed': 0.0, // Initial value
        'longest_distance': 0.0, // Initial value
        'longest_duration': 0, // Initial value
      });
    } else {
      print('User is null');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'First name',
                    focusColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    focusColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: showPasswordRequirements,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Sign up Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                  ),
                  onPressed: _loading ? null : signUp,
                  child: _loading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text('Sign Up'),
                ),
                if (_errorMessage.isNotEmpty) // Display error message if any
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),

                // Already a member? Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I am a member',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

