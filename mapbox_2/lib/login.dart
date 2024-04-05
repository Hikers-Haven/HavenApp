import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget{
  final VoidCallback showSignUpPage;
  const LoginPage ({Key? key, required this.showSignUpPage}) : super(key: key);

  @override
  State<LoginPage> createState()=> _LoginPageState();

}

class _LoginPageState extends State<LoginPage>{

  // text controllers
  final _emailController = TextEditingController();
  final  _passwordController = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';

  Future<void> handleSubmit() async {
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
  //dispose controllers to help with memory management
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // class _AuthScreenState extends State<AuthScreen>{
//   bool _isLogin = true; // Changed to true for default login screen
//   bool _loading = false;
//   String _errorMessage = ''; // Track error message
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   Future<void> handleSubmit() async {
//     if (!_formKey.currentState!.validate()) return;
//     final firstName = _firstNameController.text;
//     final email = _emailController.text;
//     final password = _passwordController.text;
//
//
//     setState(() {
//       _loading = true;
//       _errorMessage = ''; // Reset error message
//     });
//
//     try {
//       if (_isLogin) {
//         await Auth().signInWithEmailandPassword(email, password);
//       } else {
//         await Auth().registerWithEmailandPassword(email, password);
//         addUser(_emailController.text.trim());
//       }
//     } catch (error) {
//
//       String formatErrorMessage(dynamic error) {
//         String errorMessage = error.toString();
//         // Check if the error message contains '[firebase_auth/'
//         if (errorMessage.contains('[firebase_auth/')) {
//           // Remove the error code enclosed in square brackets
//           errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]'), '');
//         }
//         return errorMessage.trim(); // Trim any leading or trailing spaces
//       }
//       // Handle authentication errors here//       String errorMessage = formatErrorMessage(error);
//       setState(() {
//         _errorMessage = errorMessage;
//       });
//       print('Authentication Error: $errorMessage');
//     }
//
//
//
//     setState(() => _loading = false);
//
//
//   }

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
