import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// Import pages for navigation
import 'package:mapbox_2/pages/first_page.dart';
import 'package:mapbox_2/pages/second_page.dart';
import 'package:mapbox_2/pages/third_page.dart';
import 'package:mapbox_2/pages/fourth_page.dart';
import 'package:mapbox_2/customAppBar.dart';
import 'package:mapbox_2/pages/map_page.dart';

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
      home: MyHomePage(),
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
            ],
          ),
        ),
      ),
      body: MapPage(), // Directly use MainPage which handles all map functionalities
    );
  }
}
