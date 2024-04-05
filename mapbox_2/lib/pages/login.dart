import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  final VoidCallback showSignUpPage;
  const LoginPage ({Key? key, required this.showSignUpPage}) : super(key: key);

  @override
  State<LoginPage> createState()=> _LoginPageState();

}
  class _LoginPageState extends State<LoginPage>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';

  Future<void> handleSubmit() async{
    setState(() {
      _loading = true;
      _errorMessage = ''; // Clear any previous error message
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
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
                    "Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)
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
                  onPressed: _loading ? null : handleSubmit,
                  child: _loading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text('Sign In'),
                ),
                if (_errorMessage.isNotEmpty) // Display error message if any
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.showSignUpPage,
                      child: Text(
                        'Register now',
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
