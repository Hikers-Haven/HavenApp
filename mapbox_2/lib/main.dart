

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// Import pages for navigation
import 'package:mapbox_2/pages/first_page.dart';
import 'package:mapbox_2/pages/second_page.dart';
import 'package:mapbox_2/pages/third_page.dart';
import 'package:mapbox_2/pages/fourth_page.dart';
import 'package:mapbox_2/customAppBar.dart';
import 'package:mapbox_2/pages/main_page.dart';

import 'auth.dart';
import 'firebase_options.dart'; // Assuming this handles map functionalities

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(),
        drawer: Drawer(
          child: Container(
            color: Colors.lightGreen[300],
            child: ListView(
              children: [
                DrawerHeader(
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/peepoGamer.png'),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.details_outlined),
                  title: Text('Trail Alerts', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirstPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.tire_repair),
                  title: Text('Points of Interest', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.forum),
                  title: Text('Community', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThirdPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('Personal Progress', style: TextStyle(fontSize: 20)),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FourthPage()));
                  },
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text('Sign Out'),
                  ),
                )
              ],
            ),
          ),
        ),
        body: MapPage() // Directly use MainPage which handles all map functionalities
    );
  }
}

class AuthScreen extends StatefulWidget{
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>{
  bool _isLogin = true; // Changed to true for default login screen
  bool _loading = false;
  String _errorMessage = ''; // Track error message
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _loading = true;
      _errorMessage = ''; // Reset error message
    });

    try {
      if (_isLogin) {
        await Auth().signInWithEmailandPassword(email, password);
      } else {
        await Auth().registerWithEmailandPassword(email, password);
      }
    }
    catch (error) {

      String formatErrorMessage(dynamic error) {
        String errorMessage = error.toString();
        // Check if the error message contains '[firebase_auth/'
        if (errorMessage.contains('[firebase_auth/')) {
          // Remove the error code enclosed in square brackets
          errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]'), '');
        }
        return errorMessage.trim(); // Trim any leading or trailing spaces
      }
      // Handle authentication errors here
      String errorMessage = formatErrorMessage(error);
      setState(() {
        _errorMessage = errorMessage;
      });
      print('Authentication Error: $errorMessage');
    }



    setState(() => _loading = false);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                    "Log in / Register",
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
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () => handleSubmit(),
                    child: _loading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(_isLogin ? 'Login' : 'Register')
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin; // Toggle between login and register
                    });
                  },
                  child: Text(_isLogin ? 'Create an account' : 'Already have an account?'),
                ),
                if (_errorMessage.isNotEmpty) // Display error message if any
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
