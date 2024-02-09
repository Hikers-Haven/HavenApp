import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as LatLng;
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_2/customAppBar.dart';
// import 'package:mapbox_2/pages/fifth_page.dart';
import 'package:mapbox_2/pages/first_page.dart';
import 'package:mapbox_2/pages/second_page.dart';
import 'package:mapbox_2/pages/third_page.dart';
import 'package:mapbox_2/pages/fourth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
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
  LatLng.LatLng? _currentLocation;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
      mapController.move(_currentLocation!, 14.0); // Adjust zoom level
      setState(() {});
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng.LatLng initialLocation = _currentLocation ?? LatLng.LatLng(34.6275, -84.1935);

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
                    // ' L O G O ? ',
                    // this is a test
                    // style: TextStyle(fontSize: 35),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.details_outlined),
                title: Text('Trail Alerts', style: TextStyle(fontSize: 20),
                ),
                onTap:(){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FirstPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.tire_repair),
                title: Text('Points of Interest', style: TextStyle(fontSize: 20),
                ),
                onTap:(){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SecondPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.forum),
                title: Text('Community', style: TextStyle(fontSize: 20),
                ),
                onTap:(){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ThirdPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('Personal Progress', style: TextStyle(fontSize: 20),
                ),
                onTap:(){
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FourthPage()));
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: initialLocation,
              zoom: 14.0, // Adjust initial zoom level
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/kroye01/clrp2zg4o005z01pfcbr00eup/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
                additionalOptions: {
                  'accessToken': 'pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
                  'id': 'mapbox.mapbox-terrain-v2'
                },
              ),
              MarkerLayer(
                markers: _currentLocation != null
                    ? [
                  Marker(
                    point: LatLng.LatLng(
                      _currentLocation!.latitude,
                      _currentLocation!.longitude,
                    ),
                    width: 80,
                    height: 80,
                    child: Icon(Icons.location_on),
                  ),
                ]
                    : [],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _getLocation(); // Update location on button press
              },
              child: isLocationFound
                  ? Icon(Icons.my_location, color: Colors.white, size: 36)
                  : Icon(Icons.my_location),
              backgroundColor: isLocationFound ? Colors.deepPurple : null,
            ),
          ),
        ],
      ),
    );
  }

  bool get isLocationFound => _currentLocation != null;
}
