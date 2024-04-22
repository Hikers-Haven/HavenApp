import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart'; // Add this import

class LoginPage extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const LoginPage({Key? key, required this.showSignUpPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';

  Future<void> handleSubmit() async {
    // Use EmailValidator to validate the email format
    if (!EmailValidator.validate(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Invalid email format.';
        _loading = false; // Stop the loading process as validation fails
      });
      return; // Stop further execution if validation fails
    }

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
      handleError(error);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void handleError(dynamic error) {
    setState(() {
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'invalid-email':
            _errorMessage = 'Invalid email format.';
            break;
          case 'wrong-password':
            _errorMessage = 'Invalid password.';
            break;
          case 'user-not-found':
            _errorMessage = 'No user found for this email.';
            break;
          case 'user-disabled':
            _errorMessage = 'User has been disabled.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many requests. Try again later.';
            break;
          default:
            _errorMessage = 'An error occurred during sign in: ${error.message}';
        }
      } else {
        _errorMessage = error.toString();
      }
    });
  }

  void showPasswordRequirements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Password Requirements"),
        content: const Text("Your password must be at least 8 characters long, include an uppercase letter, a number, and a special character."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                  ),
                  onPressed: _loading ? null : handleSubmit,
                  child: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Sign In'),
                ),
                if (_errorMessage.isNotEmpty) Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red))),
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
                      child: const Text(
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
