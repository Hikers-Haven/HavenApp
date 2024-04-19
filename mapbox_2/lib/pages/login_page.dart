// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class LoginPage extends StatefulWidget{
//   final VoidCallback showSignUpPage;
//   const LoginPage ({Key? key, required this.showSignUpPage}) : super(key: key);
//
//   @override
//   State<LoginPage> createState()=> _LoginPageState();
//
// }
// class _LoginPageState extends State<LoginPage>{
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool _loading = false;
//   String _errorMessage = '';
//
//   Future<void> handleSubmit() async{
//     setState(() {
//       _loading = true;
//       _errorMessage = ''; // Clear any previous error message
//     });
//
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//     } catch (error) {
//       setState(() {
//         _errorMessage = error.toString();
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                     "Login",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _emailController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty){
//                       return 'Please enter your email';
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(
//                       hintText: 'Email',
//                       focusColor: Colors.black,
//                       focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Colors.black,
//                             width: 2,
//                           )
//                       )
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty){
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(
//                       hintText: 'Password',
//                       focusedBorder: UnderlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Colors.black,
//                               width: 2
//                           )
//                       )
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // #Sign in Button
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.lightGreenAccent,
//                   ),
//                   onPressed: _loading ? null : handleSubmit,
//                   child: _loading
//                       ? SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                       : Text('Sign In'),
//                 ),
//                 if (_errorMessage.isNotEmpty) // Display error message if any
//                   Text(
//                     _errorMessage,
//                     style: TextStyle(color: Colors.red),
//                   ),
//
//                 // not a member? register now
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Not a member?',
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.showSignUpPage,
//                       child: Text(
//                         'Register now',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          default:
            _errorMessage = 'An error occurred during sign in. ${error.message}';

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
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
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
