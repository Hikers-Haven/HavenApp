import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, SystemChannels;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _lastBearing = 0.0;
  double _currentSpeed = 0.0;
  bool _trackingStarted = false;
  bool _paused = false;
  double _distanceTraveled = 0.0;
  LatLng? _lastTrackedLocation;
  String? _userId;
  String _mapStyle = ""; // Variable to hold map style JSON
  Key _mapKey = UniqueKey();

  //i swur this gon work

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyle(); // Load map style asynchronously
    _initLocationService();
    _startCompassListener();
    _loadTrailData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString("");
    setState(() {}); // Trigger rebuild with loaded style
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _controller = Completer();
        _getCurrentLocation();
        _mapKey = UniqueKey(); // Create a new Key
      });
    }
  }

  void _reloadMap() async {
    setState(() {
      _controller = Completer();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      print('Current Location: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(position); // Update the marker
      });
      _moveCameraToCurrentLocation(); // Move camera to current location
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse) {
          throw 'Location permissions are denied.';
        }
      }

      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          _currentSpeed = position.speed * 3.6; // Convert m/s to km/h
          _currentLocation = LatLng(position.latitude, position.longitude);
          if (_trackingStarted) {
            _updateMarker(position);
            _updateMapPosition(position.latitude, position.longitude);
            if (_lastTrackedLocation != null) {
              _distanceTraveled += Geolocator.distanceBetween(
                _lastTrackedLocation!.latitude,
                _lastTrackedLocation!.longitude,
                position.latitude,
                position.longitude,
              );
            }
            _lastTrackedLocation =
                LatLng(position.latitude, position.longitude);
          }
        });
        if (!_controller.isCompleted) {
          _moveCameraToCurrentLocation();
        }
      });
    } catch (e) {
      print('Error initializing location service: $e');
    }
  }

  Future<void> _moveCameraToCurrentLocation() async {
    if (!_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null) {
      controller.moveCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  Future<void> _loadTrailData() async {
    try {
      final String geoJsonString =
          await rootBundle.loadString('assets/geodata.json');
      final data = json.decode(geoJsonString);
      final List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];
      List<LatLng> trailPoints = coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();

      // Add trail polyline
      _polylines.add(Polyline(
        polylineId: const PolylineId("trail"),
        points: trailPoints,
        color: Colors.blue,
        width: 3,
      ));

      // Define water station waypoints
      List<Map<String, dynamic>> waterStations = [
        {'name': 'Barrington Ave', 'lat': 42.101700, 'lng': -88.275384},
        {
          'name': 'Spring and N Water Street',
          'lat': 41.994857,
          'lng': -88.294895
        },
        {'name': 'State Street Bridge', 'lat': 41.994189, 'lng': -88.293600},
        {'name': 'Water and Plum Street', 'lat': 41.993449, 'lng': -88.295136},
        {'name': 'Batava River Walk', 'lat': 41.85134, 'lng': -88.30813},
        {'name': 'Island Park', 'lat': 41.88419, 'lng': -88.30224},
        {'name': 'Illinois Ave', 'lat': 41.770920, 'lng': -88.310769},
        {'name': 'Hudson Crossing Park', 'lat': 41.685517, 'lng': -88.354657},
      ];

      // Add water station markers
      for (var station in waterStations) {
        _markers.add(Marker(
          markerId: MarkerId(station['name']),
          position: LatLng(station['lat'], station['lng']),
          icon: await _createMarkerImageFromAsset('assets/watersippin.png'),
        ));
      }

      setState(() {
        // Update state with polylines and markers
      });
    } catch (e) {
      print('Failed to load GeoJSON data: $e');
    }
  }

// gets the userID
  Future<void> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String assetName) async {
    final ImageConfiguration imageConfiguration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      assetName,
    );
    return bitmapDescriptor;
  }

  void _updateMarker(Position position) async {
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId("currentLocation"),
      position: LatLng(position.latitude, position.longitude),
      icon: await _createMarkerImageFromAsset(
          'assets/navicon.png'), // Change 'your_image.png' to your asset image path
    ));
  }

  void _startCompassListener() {
    _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      final double? direction = event.heading;
      if (direction != null) {
        setState(() {
          _lastBearing = direction;
        });
        if (_trackingStarted) {
          _updateMapBearing();
        }
      }
    });
  }

  void _updateMapBearing() async {
    if (!_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _currentLocation!,
      bearing: _lastBearing,
      zoom: 14.0,
    )));
  }

  void _updateMapPosition(double lat, double lng) async {
    if (!_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.0,
    )));
  }

  void _toggleTracking() {
    setState(() {
      _trackingStarted = !_trackingStarted;
      if (_trackingStarted) {
        _distanceTraveled = 0.0; // Reset distance when tracking starts
      } else {
        // If tracking stopped, store the biking activity
        _getUserId();
        _storeBikingActivity(_userId);
      }
    });
  }

  void _recenterMap() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null) {
      controller.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  void _pauseTracking() {
    // Perform actions to pause tracking
    _positionStreamSubscription?.pause();
    _compassSubscription?.pause();
    setState(() {
      _paused = true; // Update paused state
    });
  }

  void _resumeTracking() {
    // Perform actions to resume tracking
    _positionStreamSubscription?.resume();
    _compassSubscription?.resume();
    setState(() {
      _paused = false; // Update paused state
    });
  }

  void _togglePause() {
    if (_paused) {
      _resumeTracking();
    } else {
      _pauseTracking();
    }
  }

  void _storeBikingActivity(_userId) {
    if (_userId != null && _lastTrackedLocation != null) {
      // Calculate average speed
      // Calculate distance traveled

      // Store activity in Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('biking_sessions')
          .add({
        'timestamp': DateTime.now(),
        'average_speed': _currentSpeed.toStringAsFixed(2),
        'distance_traveled': _distanceTraveled / 1609.34,
        // Convert meters to miles
      }).then((_) {
        // Successfully stored
        print('Biking activity stored successfully');
      }).catchError((error) {
        // Failed to store
        print('Failed to store biking activity: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: _mapKey,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(0, 0),
              zoom: 14.0,
            ),
            style: _mapStyle, // Apply loaded style
            polylines: _polylines,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          //button to reload map
          Positioned(
            top: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: _reloadMap,
              backgroundColor: Colors.blue,
              child: Icon(Icons.refresh),
            ),
          ),
          if (_trackingStarted)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    'Speed: ${(_currentSpeed).toStringAsFixed(2)} mph\nDistance: ${(_distanceTraveled / 1609.34).toStringAsFixed(2)} mi'),
              ),
            ),
          if (!_trackingStarted)
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _recenterMap,
                backgroundColor: Colors.blue,
                child: Icon(Icons.gps_fixed),
              ),
            ),
          Positioned(
            bottom: 20, // Adjust bottom position as needed
            right: 0, // Align the buttons to the right
            left: 0, // Align the buttons to the left
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _toggleTracking,
                    backgroundColor:
                        _trackingStarted ? Colors.red : Colors.green,
                    child: Icon(
                      _trackingStarted ? Icons.stop : Icons.play_arrow,
                    ),
                  ),
                  SizedBox(width: 16), // Add spacing between buttons if needed
                  FloatingActionButton(
                    onPressed: _togglePause,
                    backgroundColor: Colors.orange,
                    // Set the background color to orange
                    child: Icon(
                      _paused ? Icons.pause : Icons.restart_alt,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
