  // import 'dart:async';
  // import 'package:flutter/material.dart';
  // import 'package:flutter_map/flutter_map.dart';
  // import 'package:latlong2/latlong.dart' as LatLng;
  // import 'package:geolocator/geolocator.dart';
  // import 'package:mapbox_2/map_service.dart';
  // import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
  //
  // class MapPage extends StatefulWidget {
  //   @override
  //   _MapPageState createState() => _MapPageState();
  // }
  //
  // class _MapPageState extends State<MapPage> {
  //   LatLng.LatLng? _currentLocation;
  //   MapController mapController = MapController();
  //   List<LatLng.LatLng> routePoints = [];
  //   late MapBoxNavigation _navigation;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     _getLocation();
  //     _fetchAndDisplayRoute(LatLng.LatLng(42.153641, -88.287827),
  //         LatLng.LatLng(41.685342, -88.357148));
  //
  //     // Initialize navigation without the .initialize() method
  //     _navigation = MapBoxNavigation();
  //     _setDefaultNavigationOptions();
  //     _registerRouteEventListener();
  //   }
  //
  //   void _setDefaultNavigationOptions() {
  //     _navigation.setDefaultOptions(MapBoxOptions(
  //       mode: MapBoxNavigationMode.cycling,
  //       initialLatitude: 36.1175275,
  //       initialLongitude: -115.1839524,
  //       zoom: 13.0,
  //       tilt: 0.0,
  //       bearing: 0.0,
  //       enableRefresh: false,
  //       alternatives: false,
  //       voiceInstructionsEnabled: false,
  //       bannerInstructionsEnabled: true,
  //       allowsUTurnAtWayPoints: true,
  //       units: VoiceUnits.imperial,
  //       simulateRoute: false,
  //       // Changed from true to false
  //       language: "en",
  //     ));
  //   }
  //
  //   void _registerRouteEventListener() {
  //     _navigation.registerRouteEventListener(_onRouteEvent);
  //   }
  //
  //   Future<void> _onRouteEvent(RouteEvent e) async {
  //     setState(() {
  //       // Update your UI based on navigation events
  //     });
  //   }
  //
  //   void _startNavigation() async {
  //     if (_currentLocation == null || routePoints.isEmpty) {
  //       print("Current location or route points are not available.");
  //       return;
  //     }
  //
  //     final start = WayPoint(
  //       name: "Start",
  //       latitude: _currentLocation!.latitude,
  //       longitude: _currentLocation!.longitude,
  //     );
  //     final end = WayPoint(
  //       name: "End",
  //       latitude: routePoints.last.latitude,
  //       longitude: routePoints.last.longitude,
  //     );
  //
  //     // Set the profile to cycling before starting navigation
  //     MapBoxOptions options = MapBoxOptions(
  //       mode: MapBoxNavigationMode.cycling,
  //       initialLatitude: 36.1175275,
  //       initialLongitude: -115.1839524,
  //       zoom: 13.0,
  //       tilt: 0.0,
  //       bearing: 0.0,
  //       enableRefresh: false,
  //       alternatives: false,
  //       voiceInstructionsEnabled: false,
  //       bannerInstructionsEnabled: true,
  //       allowsUTurnAtWayPoints: true,
  //       units: VoiceUnits.imperial,
  //       simulateRoute: false,
  //       // Changed from true to false
  //       language: "en",
  //       // ... other settings
  //     );
  //
  //     try {
  //       await _navigation.startNavigation(wayPoints: [start, end], options: options);
  //     } catch (e) {
  //       print("Failed to start navigation: $e");
  //     }
  //   }
  //
  //
  //
  //   Future<void> _getLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     setState(() {
  //       _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
  //       mapController.move(_currentLocation!, 14.0);
  //     });
  //   } catch (e) {
  //     print("Error getting location: $e");
  //   }
  // }
  //
  // void _fetchAndDisplayRoute(LatLng.LatLng start, LatLng.LatLng end) async {
  //     List<LatLng.LatLng> waypoints = [
  //       // Manually extracted waypoints from the GPX data
  //       LatLng.LatLng(41.68544, -88.35692), // Start of route
  //       LatLng.LatLng(41.68656, -88.35156), // Turn left onto North Adams Street
  //       LatLng.LatLng(41.69334, -88.34853), // Turn right onto 2nd Street
  //       LatLng.LatLng(41.69332, -88.348), // Turn left onto Fox River Trail
  //       LatLng.LatLng(41.733, -88.33282), // Turn slight left onto Fox River Trail
  //       // Continue adding waypoints as needed...
  //       LatLng.LatLng(42.01363, -88.27478), // Example intermediate waypoint
  //       LatLng.LatLng(42.10304, -88.27689), // Example intermediate waypoint
  //       LatLng.LatLng(42.13962, -88.27753), // Example intermediate waypoint
  //       LatLng.LatLng(42.040834, -88.288288)
  //       // Add the last waypoint if it differs from the `end` parameter
  //     ];
  //
  //     List<LatLng.LatLng> fetchedRoutePoints = await MapService().fetchRoute(start, end, waypoints);
  //     setState(() {
  //       routePoints = fetchedRoutePoints;
  //     });
  //   }
  //
  //
  //
  //   @override
  //   Widget build(BuildContext context) {
  //         LatLng.LatLng initialLocation = _currentLocation ?? LatLng.LatLng(34.6275, -84.1935); // default location if current location is null
  //
  //         return Scaffold(
  //           body: Stack(
  //             children: [
  //               FlutterMap(
  //                 mapController: mapController,
  //                 options: MapOptions(
  //                   center: initialLocation, // Ensure initialLocation is of type LatLng
  //                   zoom: 14.0,
  //                 ),
  //                 children: [
  //                   TileLayer(
  //
  //                     urlTemplate: 'https://api.mapbox.com/styles/v1/coliphant01/clu2sqhr900fv01pcgdgh7ucu/tiles/256/{z}/{x}/{y}?access_token=sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg',
  //                     additionalOptions: {
  //                       'accessToken': 'sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg',
  //                     },
  //                   ),
  //
  //
  //                   PolylineLayer(
  //                     polylines: [
  //                       Polyline(
  //                         points: routePoints,
  //                         strokeWidth: 4.0,
  //                         color: Colors.blue,
  //                       )
  //                     ],
  //                   ),
  //                   MarkerLayer(
  //                     markers: _currentLocation != null
  //                         ? [
  //                       Marker(
  //                         point: _currentLocation!, // Ensure _currentLocation is of type LatLng
  //                         child: Icon(Icons.location_on, size: 40),
  //                         width: 80,
  //                         height: 80,
  //                         alignment: Alignment.center,
  //                       ),
  //                     ]
  //                         : [],
  //                   ),
  //                 ],
  //               ),
  //               Positioned(
  //                 bottom: 16,
  //                 right: 16,
  //                 child: FloatingActionButton(
  //                   onPressed: _startNavigation,
  //                   child: Icon(Icons.navigation),
  //                   backgroundColor: Colors.blue,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  // }

  // =====================================================================================================
  //
  // import 'dart:async';
  // import 'package:flutter/material.dart';
  // import 'package:flutter_map/flutter_map.dart';
  // import 'package:latlong2/latlong.dart' as LatLng;
  // import 'package:geolocator/geolocator.dart';
  // import 'package:mapbox_2/map_service.dart'; // Adjust the import path as needed
  // import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
  // import 'package:xml/xml.dart' as xml;
  // import 'package:flutter/services.dart' show rootBundle;
  //
  // class MapPage extends StatefulWidget {
  //   @override
  //   _MapPageState createState() => _MapPageState();
  // }
  //
  // class _MapPageState extends State<MapPage> {
  //   LatLng.LatLng? _currentLocation;
  //   MapController mapController = MapController();
  //   List<LatLng.LatLng> routePoints = [];
  //   late MapBoxNavigation _navigation;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     _getLocation();
  //     _loadAndDisplayRoute();
  //
  //     // Initialize navigation without the .initialize() method
  //     _navigation = MapBoxNavigation();
  //     _setDefaultNavigationOptions();
  //     _registerRouteEventListener();
  //   }
  //
  //   Future<void> _loadAndDisplayRoute() async {
  //     // Load GPX data from assets
  //     String gpxData = await rootBundle.loadString('data/traildata.gpx');
  //     List<LatLng.LatLng> waypoints = await _parseGpxData(gpxData);
  //
  //     // Assuming start and end points are the first and last waypoints
  //     _fetchAndDisplayRoute(waypoints.first, waypoints.last, waypoints);
  //   }
  //
  //   Future<List<LatLng.LatLng>> _parseGpxData(String gpxData) async {
  //     List<LatLng.LatLng> waypoints = [];
  //     final document = xml.XmlDocument.parse(gpxData);
  //     final rtepts = document.findAllElements('rtept');
  //     for (var rtept in rtepts) {
  //       final lat = double.parse(rtept.getAttribute('lat') ?? '0');
  //       final lon = double.parse(rtept.getAttribute('lon') ?? '0');
  //       waypoints.add(LatLng.LatLng(lat, lon));
  //     }
  //     return waypoints;
  //   }
  //
  //   void _fetchAndDisplayRoute(LatLng.LatLng start, LatLng.LatLng end,
  //       List<LatLng.LatLng> waypoints) async {
  //     List<LatLng.LatLng> fetchedRoutePoints = await MapService().fetchRoute(
  //         start, end, waypoints);
  //     setState(() {
  //       routePoints = fetchedRoutePoints;
  //     });
  //   }
  //
  //   void _setDefaultNavigationOptions() {
  //     _navigation.setDefaultOptions(MapBoxOptions(
  //       initialLatitude: 36.1175275,
  //       initialLongitude: -115.1839524,
  //       zoom: 13.0,
  //       tilt: 0.0,
  //       bearing: 0.0,
  //       enableRefresh: false,
  //       alternatives: true,
  //       voiceInstructionsEnabled: true,
  //       bannerInstructionsEnabled: true,
  //       allowsUTurnAtWayPoints: true,
  //       mode: MapBoxNavigationMode.cycling,
  //       units: VoiceUnits.imperial,
  //       simulateRoute: false,
  //       language: "en",
  //     ));
  //   }
  //
  //   void _registerRouteEventListener() {
  //     _navigation.registerRouteEventListener(_onRouteEvent);
  //   }
  //
  //   Future<void> _onRouteEvent(RouteEvent e) async {
  //     setState(() {
  //       // Update your UI based on navigation events
  //     });
  //   }
  //
  //   void _startNavigation() async {
  //     if (_currentLocation == null || routePoints.isEmpty) {
  //       print("Current location or route points are not available.");
  //       return;
  //     }
  //
  //     final start = WayPoint(name: "Start",
  //         latitude: _currentLocation!.latitude,
  //         longitude: _currentLocation!.longitude);
  //     final end = WayPoint(name: "End",
  //         latitude: routePoints.last.latitude,
  //         longitude: routePoints.last.longitude);
  //
  //     var wayPoints = <WayPoint>[start, end];
  //
  //     await _navigation.startNavigation(wayPoints: wayPoints);
  //   }
  //
  //   Future<void> _getLocation() async {
  //     try {
  //       Position position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.high);
  //       setState(() {
  //         _currentLocation =
  //             LatLng.LatLng(position.latitude, position.longitude);
  //         mapController.move(_currentLocation!, 14.0);
  //       });
  //     } catch (e) {
  //       print("Error getting location: $e");
  //     }
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     LatLng.LatLng initialLocation = _currentLocation ??
  //         LatLng.LatLng(34.6275, -84.1935);
  //     return Scaffold(
  //       body: Stack(
  //         children: [
  //           FlutterMap(
  //             mapController: mapController,
  //             options: MapOptions(
  //               center: initialLocation,
  //               // Ensure initialLocation is of type LatLng
  //               zoom: 14.0,
  //             ),
  //             children: [
  //               TileLayer(
  //                 urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
  //                 additionalOptions: {
  //                   'accessToken': 'sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg',
  //                 },
  //               ),
  //
  //
  //               PolylineLayer(
  //                 polylines: [
  //                   Polyline(
  //                     points: routePoints,
  //                     strokeWidth: 4.0,
  //                     color: Colors.blue,
  //                   )
  //                 ],
  //               ),
  //               MarkerLayer(
  //                 markers: _currentLocation != null
  //                     ? [
  //                   Marker(
  //                     point: _currentLocation!,
  //                     // Ensure _currentLocation is of type LatLng
  //                     child: Icon(Icons.location_on, size: 40),
  //                     width: 80,
  //                     height: 80,
  //                     alignment: Alignment.center,
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
  //               onPressed: _startNavigation,
  //               child: Icon(Icons.navigation),
  //               backgroundColor: Colors.blue,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
  //=====================================================================================================

  // import 'dart:async';
  // import 'package:flutter/material.dart';
  // import 'package:flutter_map/flutter_map.dart';
  // import 'package:geolocator/geolocator.dart';
  // import 'package:latlong2/latlong.dart';
  //
  // class MapPage extends StatefulWidget {
  //   @override
  //   _MapPageState createState() => _MapPageState();
  // }
  //
  // class _MapPageState extends State<MapPage> {
  //   LatLng? _currentLocation;
  //   late MapController mapController;
  //   StreamSubscription<Position>? positionStream;
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     mapController = MapController();
  //     _requestPermission().then((_) {
  //       _startLocationTracking();
  //     });
  //   }
  //
  //   @override
  //   void dispose() {
  //     positionStream?.cancel();
  //     super.dispose();
  //   }
  //
  //   Future<void> _requestPermission() async {
  //     LocationPermission permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   void _startLocationTracking() {
  //     positionStream = Geolocator.getPositionStream().listen((Position position) {
  //       setState(() {
  //         _currentLocation = LatLng(position.latitude, position.longitude);
  //       });
  //       // Directly move the map center without checking 'ready'
  //       mapController.move(_currentLocation!, 14.0);
  //     });
  //   }
  //
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     LatLng initialLocation = _currentLocation ?? LatLng(34.6275, -84.1935); // default location if current location is null
  //
  //     return Scaffold(
  //       body: Stack(
  //         children: [
  //           FlutterMap(
  //             mapController: mapController,
  //             options: MapOptions(
  //               center: initialLocation,
  //               // Ensure initialLocation is of type LatLng
  //               zoom: 14.0,
  //             ),
  //             children: [
  //               TileLayer(
  //                 urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
  //                 additionalOptions: {
  //                   'accessToken': 'sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg',
  //                 },
  //               ),
  //
  //
  //               PolylineLayer(
  //                 polylines: [
  //                   Polyline(
  //                     points: [],
  //                     strokeWidth: 4.0,
  //                     color: Colors.blue,
  //                   )
  //                 ],
  //               ),
  //               MarkerLayer(
  //                 markers: _currentLocation != null
  //                     ? [
  //                   Marker(
  //                     point: _currentLocation!,
  //                     // Ensure _currentLocation is of type LatLng
  //                     child: Icon(Icons.location_on, size: 40),
  //                     width: 80,
  //                     height: 80,
  //                     alignment: Alignment.center,
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
  //               onPressed: null,
  //               child: Icon(Icons.navigation),
  //               backgroundColor: Colors.blue,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
  //
  //=====================================================================================================

  // import 'dart:convert';
  // import 'package:flutter_map/flutter_map.dart';
  // import 'package:flutter/services.dart' show rootBundle;
  // import 'package:flutter/material.dart';
  // import 'package:latlong2/latlong.dart' as LatLng;
  // import 'package:at_location_flutter/at_location_flutter.dart';
  //
  //
  // class MapPage extends StatefulWidget {
  //   @override
  //   _MapPageState createState() => _MapPageState();
  // }
  //
  // class _MapPageState extends State<MapPage> {
  //   List<LatLng.LatLng> trailPoints = [];
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     _loadTrailData();
  //   }
  //
  //   Future<void> _loadTrailData() async {
  //     try {
  //       // Load JSON data from the assets folder
  //       String data = await rootBundle.loadString('assets/trail_data.json');
  //       // Parse the JSON data
  //       List<dynamic> jsonList = json.decode(data);
  //       // Extract latitude and longitude coordinates
  //       List<LatLng.LatLng> points = jsonList.map((e) {
  //         double lat = e['latitude'];
  //         double lng = e['longitude'];
  //         return LatLng.LatLng(lat, lng);
  //       }).toList();
  //       // Set the trail points
  //       setState(() {
  //         trailPoints = points;
  //       });
  //     } catch (e) {
  //       print("Error loading trail data: $e");
  //     }
  //   }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     LatLng.LatLng initialLocation = trailPoints.isNotEmpty
  //         ? trailPoints.first // Use the first point as initial location
  //         : LatLng.LatLng(
  //         34.6275, -84.1935); // default location if trailPoints is empty
  //
  //     return Scaffold(
  //       body: FlutterMap(
  //         options: MapOptions(
  //           center: initialLocation,
  //           zoom: 14.0,
  //         ),
  //         layers: [
  //           TileLayerOptions(
  //             urlTemplate: 'https://api.mapbox.com/styles/v1/coliphant01/clu2sqhr900fv01pcgdgh7ucu/tiles/256/{z}/{x}/{y}?access_token=sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg',
  //           ),
  //           PolylineLayerOptions(
  //             polylines: [
  //               Polyline(
  //                 points: trailPoints,
  //                 strokeWidth: 4.0,
  //                 color: Colors.blue,
  //               )
  //             ],
  //           ),
  //           MarkerLayerOptions(
  //             markers: trailPoints.map((point) {
  //               return Marker(
  //                 point: point,
  //                 width: 80,
  //                 height: 80,
  //                 builder: (ctx) => Container(
  //                   child: Icon(
  //                     Icons.location_on,
  //                     size: 40,
  //                     color: Colors.green,
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //           AtLocationFlutter()
  //         ],
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: () {
  //           // Add your navigation logic here
  //         },
  //         child: Icon(Icons.navigation),
  //         backgroundColor: Colors.blue,
  //       ),
  //     );
  //
  //   }
  // }
  //=====================================================================================================

  import 'dart:async';
  import 'dart:convert';
  import 'dart:math';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart' as LatLng;
  import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, LocationSettings, Position;
  import 'package:flutter/services.dart' show DeviceOrientation, rootBundle;
  import 'package:syncfusion_flutter_gauges/gauges.dart';
  import 'package:sensors_plus/sensors_plus.dart';
  import 'package:location/location.dart' as loc;

  class MapPage extends StatefulWidget {
    @override
    _MapPageState createState() => _MapPageState();
  }

  class _MapPageState extends State<MapPage> {
    LatLng.LatLng? _currentLocation;
    MapController mapController = MapController();
    List<LatLng.LatLng> trailPoints = [];
    StreamSubscription<Position>? _positionStreamSubscription;
    StreamSubscription<GyroscopeEvent>? _orientationSubscription;

    double _currentSpeed = 0.0; // Current speed of the user in km/h
    bool _isTrackingStarted =
    false; // State variable to control speedometer visibility
    double _heading = 0.0; // Current device orientation in degrees

    @override
    //hey this a comment for pushing lul
    void initState() {
      super.initState();
      _initLocationService();
      _loadTrailData();
      _startOrientationListener();
    }

    void _initLocationService() async {
      loc.Location location = loc.Location();

      bool serviceEnabled;
      loc.PermissionStatus permission;

      // Check if location services are enabled
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          // Location services are still not enabled, handle accordingly
          return;
        }
      }

      // Check location permissions
      permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          // Location permissions are not granted, handle accordingly
          return;
        }
      }

      // Start listening to location changes and update camera position
      location.onLocationChanged.listen((loc.LocationData currentLocation) {
        setState(() {
          _currentLocation = LatLng.LatLng(currentLocation.latitude!, currentLocation.longitude!);
          mapController.move(_currentLocation!, 14.0);
        });
      });

      // Get the initial location and center the camera
      loc.LocationData initialLocation = await location.getLocation();
      setState(() {
        _currentLocation = LatLng.LatLng(initialLocation.latitude!, initialLocation.longitude!);
        mapController.move(_currentLocation!, 14.0);
      });
    }

    void startTracking() {
      if (_positionStreamSubscription != null) {
        // Prevent multiple subscriptions
        return;
      }

      const locationSettings = LocationSettings(
        accuracy:LocationAccuracy.high,
        distanceFilter: 10,
      );
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings).listen(
                (Position? position) {
              if (position != null) {
                setState(() {
                  _currentLocation =
                      LatLng.LatLng(position.latitude, position.longitude);
                  _currentSpeed = position.speed * 3.6; // Convert m/s to km/h
                  mapController.move(_currentLocation!, 14.0);
                });
              }
            },
          );
      setState(() {
        _isTrackingStarted = true;
      });
    }

    void stopTracking() {
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null; // Reset the subscription
      setState(() {
        _isTrackingStarted = false;
      });
    }

    void _startOrientationListener() {
      if (_orientationSubscription != null) {
        // If the subscription exists, don't create a new one.
        return;
      }

      _orientationSubscription =
          gyroscopeEventStream().listen((GyroscopeEvent event) {
            // Logic remains the same.
            final double x = event.x;
            final double y = event.y;
            final double radians = atan2(y, x);
            final double degrees = radians * (180 / pi);
            setState(() {
              _heading = degrees;
            });
          });
    }

    @override
    void dispose() {
      _positionStreamSubscription?.cancel();
      _orientationSubscription?.cancel();
      super.dispose();
    }

    Future<void> _loadTrailData() async {
      try {
        final String geoJsonString =
        await rootBundle.loadString('assets/geodata.json');
        final data = json.decode(geoJsonString);
        final List<dynamic> coordinates =
        data['features'][0]['geometry']['coordinates'];
        setState(() {
          trailPoints = coordinates
              .map<LatLng.LatLng>((coord) => LatLng.LatLng(coord[1], coord[0]))
              .toList();
        });
      } catch (e) {
        print('Failed to load GeoJSON data: $e');
      }
    }

  @override
  Widget build(BuildContext context) {
    LatLng.LatLng initialLocation = _currentLocation ??
        LatLng.LatLng(
            34.6275, -84.1935); // default location if current location is null

    return Scaffold(
      body: Stack(
        children: [
          Transform.rotate(
            angle: _heading * (pi / 180), // Convert degrees to radians
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: initialLocation,
                zoom: 40.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/coliphant01/clu2sqhr900fv01pcgdgh7ucu/tiles/256/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: const {
                    'accessToken':
                        'sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg',
                  },
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: trailPoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    )
                  ],
                ),
                MarkerLayer(
                  markers: _currentLocation != null
                      ? [
                          Marker(
                            point: _currentLocation!,
                            // Ensure _currentLocation is of type LatLng
                            child: Icon(
                              CupertinoIcons.location_north_fill,
                              size: 30,
                              color: Colors.red,
                            ),
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            rotate: true, // Rotate the marker icon
                          ),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          if (_isTrackingStarted)
            // Conditional rendering based on _isTrackingStarted
            Positioned(
              bottom: 80,
              left: 20,
              child: Container(
                width: 180,
                height: 180,
                child: SfRadialGauge(
                    // Your existing speedometer setup
                    ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_isTrackingStarted) {
                  stopTracking(); // Stop tracking when button is pressed again
                } else {
                  startTracking(); // Start tracking when button is pressed
                }
              },
              child: _isTrackingStarted
                  ? Icon(Icons.stop)
                  : Icon(Icons.play_arrow),
              backgroundColor: _isTrackingStarted ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
