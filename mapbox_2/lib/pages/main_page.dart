  // import 'dart:async';
  // import 'package:flutter/material.dart';
  // import 'package:flutter_map/flutter_map.dart';
  // import 'package:latlong2/latlong.dart' as LatLng;
  // import 'package:geolocator/geolocator.dart';
  // import 'package:mapbox_2/map_service.dart';
  //
  // class MapPage extends StatefulWidget {
  //   @override
  //   _MapPageState createState() => _MapPageState();
  // }
  //
  // class _MapPageState extends State<MapPage> {
  //   LatLng.LatLng? _currentLocation;
  //   MapController mapController = MapController();
  //   List<LatLng.LatLng> routePoints = []; // This will hold the fetched route points
  //
  //   @override
  //   void initState() {
  //     super.initState();
  //     // _getLocationPeriodically();
  //     _getLocation();
  //
  //
  //     _fetchAndDisplayRoute(LatLng.LatLng(42.153641, -88.287827), LatLng.LatLng(41.685342, -88.357148));
  //   }
  //
  //
  //   void _fetchAndDisplayRoute(LatLng.LatLng start, LatLng.LatLng end) async {
  //     List<LatLng.LatLng> waypoints = [
  //       LatLng.LatLng(42.042287, -88.288738), // Waypoint 1
  //       LatLng.LatLng(42.040834, -88.288288), // Waypoint 2
  //     ];
  //     List<LatLng.LatLng> fetchedRoutePoints = await MapService().fetchRoute(start, end, waypoints);
  //     setState(() {
  //       routePoints = fetchedRoutePoints;
  //     });
  //   }
  //
  //
  //   // void _getLocationPeriodically() {
  //   //   // Periodically fetch the user's location every 5 seconds
  //   //   const duration = Duration(milliseconds: 50);
  //   //   Timer.periodic(duration, (timer) async {
  //   //     try {
  //   //       Position position = await Geolocator.getCurrentPosition();
  //   //       setState(() {
  //   //         _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
  //   //       });
  //   //     } catch (e) {
  //   //       print("Error getting location: $e");
  //   //     }
  //   //   });
  //   // }
  //
  //   Future<void> _getLocation() async {
  //     try {
  //       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //       setState(() {
  //         _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
  //         mapController.move(_currentLocation!, 14.0); // Adjust zoom level
  //       });
  //     } catch (e) {
  //       print("Error getting location: $e");
  //     }
  //   }
  //
  //   // void _recenterMap() {
  //   //   // Recenter the map to the user's current location
  //   //   if (_currentLocation != null) {
  //   //     mapController.move(_currentLocation!, 14.0); // Adjust zoom level
  //   //   }
  //   // }
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     LatLng.LatLng initialLocation = _currentLocation ?? LatLng.LatLng(34.6275, -84.1935); // default location if current location is null
  //
  //     return Scaffold(
  //       body: Stack(
  //         children: [
  //           FlutterMap(
  //             mapController: mapController,
  //             options: MapOptions(
  //               center: initialLocation, // Ensure initialLocation is of type LatLng
  //               zoom: 14.0,
  //             ),
  //             children: [
  //               TileLayer(
  //                 urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/outdoors-v11/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
  //                 additionalOptions: {
  //                   'accessToken': 'pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
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
  //                     point: _currentLocation!, // Ensure _currentLocation is of type LatLng
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
  //               onPressed: _getLocation,
  //               child: Icon(Icons.my_location),
  //               backgroundColor: Colors.blue,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

//----------------------------------------


  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart' as LatLng;
  import 'package:geolocator/geolocator.dart';
  import 'package:mapbox_2/map_service.dart';
  import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

  class MapPage extends StatefulWidget {
    @override
    _MapPageState createState() => _MapPageState();
  }

  class _MapPageState extends State<MapPage> {
    LatLng.LatLng? _currentLocation;
    MapController mapController = MapController();
    List<LatLng.LatLng> routePoints = [];
    late MapBoxNavigation _navigation;

    @override
    void initState() {
      super.initState();
      _getLocation();
      _fetchAndDisplayRoute(LatLng.LatLng(42.153641, -88.287827), LatLng.LatLng(41.685342, -88.357148));

      // Initialize navigation
      _navigation = MapBoxNavigation();
      _initializeNavigation();
      _registerRouteEventListener();
    }

    Future<void> _initializeNavigation() async {
      // await _navigation.initialize();
      _navigation.setDefaultOptions(MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.cycling,
        units: VoiceUnits.imperial,
        simulateRoute: true,
        language: "en",
      ));
    }

    void _registerRouteEventListener() {
      _navigation.registerRouteEventListener(_onRouteEvent);
    }

    Future<void> _onRouteEvent(RouteEvent e) async {
      // Handle navigation events
      setState(() {
        // Update your UI based on navigation events
      });
    }

    void _startNavigation() async {
      // Ensure current location and at least one waypoint is available
      if (_currentLocation == null || routePoints.isEmpty) {
        print("Current location or route points are not available.");
        return;
      }

      final start = WayPoint(name: "Start", latitude: _currentLocation!.latitude, longitude: _currentLocation!.longitude);
      final end = WayPoint(name: "End", latitude: routePoints.last.latitude, longitude: routePoints.last.longitude);

      var wayPoints = <WayPoint>[start, end];
      // Add any additional waypoints if necessary

      await _navigation.startNavigation(wayPoints: wayPoints);
    }

    Future<void> _getLocation() async {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
          mapController.move(_currentLocation!, 14.0);
        });
      } catch (e) {
        print("Error getting location: $e");
      }
    }

    void _fetchAndDisplayRoute(LatLng.LatLng start, LatLng.LatLng end) async {
      List<LatLng.LatLng> waypoints = [
        LatLng.LatLng(42.042287, -88.288738), // Waypoint 1
        LatLng.LatLng(42.040834, -88.288288), // Waypoint 2
      ];
      List<LatLng.LatLng> fetchedRoutePoints = await MapService().fetchRoute(start, end, waypoints);
      setState(() {
        routePoints = fetchedRoutePoints;
      });
    }


    @override
    Widget build(BuildContext context) {
          LatLng.LatLng initialLocation = _currentLocation ?? LatLng.LatLng(34.6275, -84.1935); // default location if current location is null

          return Scaffold(
            body: Stack(
              children: [
                FlutterMap(
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
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        )
                      ],
                    ),
                    MarkerLayer(
                      markers: _currentLocation != null
                          ? [
                        Marker(
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
                    onPressed: _startNavigation,
                    child: Icon(Icons.navigation),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        }
  }
