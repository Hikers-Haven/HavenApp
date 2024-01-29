import 'package:flutter/material.dart';
import 'package:mapbox_2/customAppBar.dart';
import 'package:mapbox_2/pages/fifth_page.dart';
import 'package:mapbox_2/pages/first_page.dart';
import 'package:mapbox_2/pages/second_page.dart';
import 'package:mapbox_2/pages/third_page.dart';
import 'package:mapbox_2/pages/fourth_page.dart';
import 'package:mapbox_2/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
  State<MyHomePage> createState() => _MyHomePageState();
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
                  child: Text(
                    ' L O G O ? ',
                    style: TextStyle(fontSize: 35),
                  ),
                ),
              ),

              ListTile(
                leading: Icon(Icons.forum),
                title: Text(
                  'forum',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FirstPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.browse_gallery),
                title: Text(
                  'gallery',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SecondPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_month),
                title: Text(
                  'planner',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ThirdPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.note_add),
                title: Text(
                  'notes',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FourthPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.route),
                title: Text(
                  'saved paths',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FifthPage()),
                  );
                },
              ),
            ],
          ),

        ),
      ),
      body: Center(
        child: MapPage(), // Replace the Text widget with your MapPage widget
      ),
    );
  }
}
