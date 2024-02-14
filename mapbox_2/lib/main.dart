// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart' as LatLng;
// import 'package:geolocator/geolocator.dart';
// import 'package:mapbox_2/customAppBar.dart';
// // import 'package:mapbox_2/pages/fifth_page.dart';
// import 'package:mapbox_2/pages/first_page.dart';
// import 'package:mapbox_2/pages/second_page.dart';
// import 'package:mapbox_2/pages/third_page.dart';
// import 'package:mapbox_2/pages/fourth_page.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // title: 'Flutter Demo',
//       // theme: ThemeData(
//       //   colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
//       //   useMaterial3: true,
//       // ),
//       debugShowCheckedModeBanner: false,
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   LatLng.LatLng? _currentLocation;
//   MapController mapController = MapController();
//
//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//   }
//
//   Future<void> _getLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
//       mapController.move(_currentLocation!, 14.0); // Adjust zoom level
//       setState(() {});
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     LatLng.LatLng initialLocation = _currentLocation ?? LatLng.LatLng(34.6275, -84.1935);
//
//     return Scaffold(
//       appBar: customAppBar(),
//       drawer: Drawer(
//         child: Container(
//           color: Colors.lightGreen[300],
//           child: ListView(
//             children: [
//               DrawerHeader(
//                 child: Center(
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundImage: AssetImage('assets/peepoGamer.png'),
//                     // ' L O G O ? ',
//                     // this is a test
//                     // style: TextStyle(fontSize: 35),
//                   ),
//                 ),
//               ),
//               ListTile(
//                 leading: Icon(Icons.details_outlined),
//                 title: Text('Trail Alerts', style: TextStyle(fontSize: 20),
//                 ),
//                 onTap:(){
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => FirstPage()));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.tire_repair),
//                 title: Text('Points of Interest', style: TextStyle(fontSize: 20),
//                 ),
//                 onTap:(){
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => SecondPage()));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.forum),
//                 title: Text('Community', style: TextStyle(fontSize: 20),
//                 ),
//                 onTap:(){
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => ThirdPage()));
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.bar_chart),
//                 title: Text('Personal Progress', style: TextStyle(fontSize: 20),
//                 ),
//                 onTap:(){
//                   Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => FourthPage()));
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//               center: initialLocation,
//               zoom: 14.0, // Adjust initial zoom level
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://api.mapbox.com/styles/v1/kroye01/clrp2zg4o005z01pfcbr00eup/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
//                 additionalOptions: {
//                   'accessToken': 'pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
//                   'id': 'mapbox.mapbox-terrain-v2'
//                 },
//               ),
//               MarkerLayer(
//                 markers: _currentLocation != null
//                     ? [
//                   Marker(
//                     point: LatLng.LatLng(
//                       _currentLocation!.latitude,
//                       _currentLocation!.longitude,
//                     ),
//                     width: 80,
//                     height: 80,
//                     child: Icon(Icons.location_on),
//                   ),
//                 ]
//                     : [],
//               ),
//             ],
//           ),
//           Positioned(
//             bottom: 16,
//             right: 16,
//             child: FloatingActionButton(
//               onPressed: () {
//                 _getLocation(); // Update location on button press
//               },
//               child: isLocationFound
//                   ? Icon(Icons.my_location, color: Colors.white, size: 36)
//                   : Icon(Icons.my_location),
//               backgroundColor: isLocationFound ? Colors.deepPurple : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   bool get isLocationFound => _currentLocation != null;
// }


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as LatLng;
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_2/customAppBar.dart';
// Assuming these pages exist and are correctly implemented
import 'package:mapbox_2/pages/first_page.dart';
import 'package:mapbox_2/pages/second_page.dart';
import 'package:mapbox_2/pages/third_page.dart';
import 'package:mapbox_2/pages/fourth_page.dart';
import 'map_service.dart';

void main() {
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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng.LatLng? _currentLocation;
  final MapController mapController = MapController();
  List<LatLng.LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
    // Fetch and display the route upon initialization
    // Update these coordinates with the actual start and end points of the Fox River Trail
    _fetchAndDisplayRoute(LatLng.LatLng(42.153641, -88.287827), LatLng.LatLng(41.685342, -88.357148));
  }

  Future<void> _fetchAndDisplayRoute(LatLng.LatLng start, LatLng.LatLng end) async {
    try {
      routePoints = await MapService().fetchRoute(start, end);
      setState(() {});
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
        mapController.move(_currentLocation!, 14.0); // Adjust zoom level
      });
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
            // key: UniqueKey(),
            mapController: mapController,
            options: MapOptions(
              center: initialLocation, // Ensure initialLocation is of type LatLng
              zoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': 'pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
                },
              ),


              PolylineLayer(
                // key: UniqueKey(),
                polylines: [
                  Polyline(
                    points: routePoints, // Ensure _buildTrail() returns List<LatLng>
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  )
                ],
              ),
              MarkerLayer(
                // key: UniqueKey(),
                markers: _currentLocation != null
                    ? [
                  Marker(
                    // key: ValueKey(_currentLocation), // Ensure ValueKey is of type LatLng
                    point: _currentLocation!, // Ensure _currentLocation is of type LatLng
                    child: Icon(Icons.location_on, size: 40),
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
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
              onPressed: _getLocation,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  bool get isLocationFound => _currentLocation != null;
}

