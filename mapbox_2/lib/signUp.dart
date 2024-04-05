import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final  _passwordController = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';

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
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // stores this data when the user signs up
    Future addUserDetails(String email, String firstName) async {
    await FirebaseFirestore.instance.collection('users').add({
      'Email': email,
      'Name': firstName,
      'Registration Date': DateTime.now(),


    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            //key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    "Register",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)
                ),
                const SizedBox(height: 20),
                TextFormField(
                  //controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty){
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
                          )
                      )
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty){
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
                          )
                      )
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty){
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: 'Password',
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black,
                              width: 2
                          )
                      )
                  ),
                ),
                const SizedBox(height: 20),
                // #Sign in Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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

                // already a member? signUp
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I am a member',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
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
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}


