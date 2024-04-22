import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// Import pages for navigation
import 'package:mapbox_2/pages/first_page.dart';
import 'package:mapbox_2/pages/second_page.dart';
import 'package:mapbox_2/pages/progress_page.dart';
import 'package:mapbox_2/customAppBar.dart';
import 'package:mapbox_2/pages/map_page.dart';

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
            return const Auth();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: MyHomePage.scaffoldKey,
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
                      backgroundColor: Colors.orange[300],  // Background color for the circle
                      child: Icon(
                        Icons.person,  // Material Icon for person
                        size: 80,
                        color: Colors.grey[800],  // Icon color
                      ),
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
                // Inside the onTap of the ListTile that navigates to SecondPage
                ListTile(
                  leading: Icon(Icons.tire_repair),
                  title: Text('Points of Interest', style: TextStyle(fontSize: 20)),
                  onTap: () async {
                    // Close the drawer first
                    MyHomePage.scaffoldKey.currentState?.openEndDrawer();
                    // Navigate and wait for the result
                    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondPage()));
                    if (result != null && result.containsKey('latitude') && result.containsKey('longitude')) {
                      double latitude = double.parse(result['latitude']);
                      double longitude = double.parse(result['longitude']);

                      // Access the state of MapPage using the GlobalKey
                      if (MapPage.mapKey.currentState != null && !MapPage.mapKey.currentState!.trackingIsActive()) {
                        MapPage.mapKey.currentState!.updateMapWithLocation(latitude, longitude);
                      }
                    }
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
                  padding: EdgeInsets.all(16.0), // Adds padding around the button for better spacing
                  child: Center(
                    child: SizedBox(
                      width: 400,
                      height: 30,// Specify the width you want for your button
                      child: ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder( // Adds rounded corners to the button
                                borderRadius: BorderRadius.circular(8)
                            )
                        ),
                        child: Text('Sign Out'),
                      ),
                    ),
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

