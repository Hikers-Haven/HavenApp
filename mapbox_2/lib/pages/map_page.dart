import 'dart:collection';
import 'package:firebase_database/firebase_database.dart';
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
  const MapPage({super.key});

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
  // late DateTime _startTime;
  LatLng? _lastTrackedLocation;
  // String? _userId;
  String _mapStyle = "assets/map_style.json"; // Variable to hold map style JSON
  Key _mapKey = UniqueKey();

  Timer? _trackingTimer;
  int _elapsedSeconds = 0;
  // Queue<double> _recentSpeeds = Queue();
  // int _maxQueueSize = 5;

  // static const double speedThreshold = 0.5; // Speed threshold in m/s

  // Position? _previousPosition;
  DateTime? _previousPositionTime;

  late DateTime _sessionStart;
  late DateTime _sessionEnd;
  Duration _pausedDuration = Duration.zero;
  late DateTime _lastPauseTime;
  final Queue<double> _speeds = Queue<double>(); // To keep track of all valid speed measurements

  double maxDistancePerSecond = 15.0;

  double plausibleSpeedLimit = 30.0;

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
    _mapStyle = await rootBundle.loadString("assets/map_style.json");
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Current Location: ${position.latitude}, ${position.longitude}');
      _updateLocation(position);
    } on PermissionDeniedException {
      print('Location permissions are denied');
      // Handle this exception specifically
    } on LocationServiceDisabledException {
      print('Location services are disabled');
      // Handle this exception specifically
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMarker(position); // Update the marker
    });
    _moveCameraToCurrentLocation(); // Move camera to current location
  }

  // void _initLocationService() async {
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       throw 'Location services are disabled.';
  //     }
  //
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
  //         if (mounted) {
  //           await showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: const Text('Location Permission Required'),
  //                 content: const Text('This app needs location permissions to function. Please grant location permission.'),
  //                 actions: <Widget>[
  //                   TextButton(
  //                     child: const Text('OK'),
  //                     onPressed: () {
  //                       SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         }
  //       }
  //     }
  //     var locationSettings = const LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 5,
  //     );
  //
  //     _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
  //       if (_paused) return; // Ignore updates while paused
  //       if (position.accuracy > 50) return; // Continue to ignore if accuracy is too low
  //
  //       final LatLng newLocation = LatLng(position.latitude, position.longitude);
  //       if (_lastTrackedLocation != null) {
  //         final double distanceMeters = Geolocator.distanceBetween(
  //             _lastTrackedLocation!.latitude,
  //             _lastTrackedLocation!.longitude,
  //             newLocation.latitude,
  //             newLocation.longitude
  //         );
  //
  //         // Convert distance from meters to miles
  //         final double distanceMiles = distanceMeters * 0.000621371;
  //         _distanceTraveled += distanceMiles; // Add the converted distance in miles
  //         // Calculate speed
  //         if (_previousPositionTime != null) {
  //           final DateTime currentTime = DateTime.now();
  //           final int timeDifferenceInSeconds = currentTime.difference(_previousPositionTime!).inSeconds;
  //           if (timeDifferenceInSeconds > 0) {
  //             final double speedInMetersPerSecond = distanceMeters / timeDifferenceInSeconds;
  //             final double speedInMph = speedInMetersPerSecond * 2.23694; // Convert speed from m/s to mph
  //             _currentSpeed = speedInMph;
  //           }
  //           _previousPositionTime = currentTime;
  //         }
  //
  //         _lastTrackedLocation = newLocation;
  //         _previousPositionTime = DateTime.now();
  //
  //         if (!_controller.isCompleted) {
  //           _moveCameraToCurrentLocation();
  //         }
  //       } else {
  //         _lastTrackedLocation = newLocation;
  //         _previousPositionTime = DateTime.now();
  //       }
  //     });
  //   } catch (e) {
  //     print('Error initializing location service: $e');
  //   }
  // }
  void _initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text('This app needs location permissions to function. Please grant location permission.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      }
      var locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      double maxDistancePerSecond = 15.0; // Maximum plausible distance per second

      _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
        if (_paused) return; // Ignore updates while paused
        if (position.accuracy > 50) return; // Continue to ignore if accuracy is too low

        final LatLng newLocation = LatLng(position.latitude, position.longitude);
        if (_lastTrackedLocation != null) {
          final double distanceMeters = Geolocator.distanceBetween(
              _lastTrackedLocation!.latitude,
              _lastTrackedLocation!.longitude,
              newLocation.latitude,
              newLocation.longitude
          );

          final DateTime currentTime = DateTime.now();
          final int timeDifferenceInSeconds = (_previousPositionTime != null) ? currentTime.difference(_previousPositionTime!).inSeconds : 0;

          if (distanceMeters > maxDistancePerSecond * timeDifferenceInSeconds) {
            return; // Skip this update as it's likely an error
          }

          // Convert distance from meters to miles
          final double distanceMiles = distanceMeters * 0.000621371;
          _distanceTraveled += distanceMiles; // Add the converted distance in miles

          // // Calculate speed
          // if (timeDifferenceInSeconds > 0) {
          //   final double speedInMetersPerSecond = distanceMeters / timeDifferenceInSeconds;
          //   final double speedInMph = speedInMetersPerSecond * 2.23694; // Convert speed from m/s to mph
          //   _currentSpeed = speedInMph;
          // }
          if (timeDifferenceInSeconds > 0) {
            final double speedInMetersPerSecond = distanceMeters / timeDifferenceInSeconds;
            final double speedInMph = speedInMetersPerSecond * 2.23694; // Convert speed from m/s to mph
            if (speedInMph <= plausibleSpeedLimit && speedInMph > 0) { // Ensure non-negative, realistic speeds
              _currentSpeed = speedInMph;
              _speeds.add(speedInMph); // Add to speed tracking for average speed calculation
            }
          }


          _lastTrackedLocation = newLocation;
          _previousPositionTime = currentTime;

          if (!_controller.isCompleted) {
            _moveCameraToCurrentLocation();
          }
        } else {
          _lastTrackedLocation = newLocation;
          _previousPositionTime = DateTime.now();
        }
      });
    } catch (e) {
      print('Error initializing location service: $e');
    }
  }



  Future<void> _moveCameraToCurrentLocation() async {
    if (!_controller.isCompleted || _trackingStarted) return;
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

      // Load water station waypoints from JSON file
      final String waterStationsJsonString =
      await rootBundle.loadString('assets/waterspots.json');
      List<Map<String, dynamic>> waterStations = List<Map<String, dynamic>>.from(json.decode(waterStationsJsonString));

      // Add water station markers
      for (var station in waterStations) {
        _markers.add(Marker(
          markerId: MarkerId(station['name']),
          position: LatLng(station['lat'], station['lng']),
          icon: await _createMarkerImageFromAsset('assets/watersippin.png'),
        ));
      }

      setState((){});

    } catch (e) {
      print('Failed to load GeoJSON data: $e');
    }
  }

// gets the userID
  Future<String?> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String assetName) async {
    const ImageConfiguration imageConfiguration = ImageConfiguration(devicePixelRatio: 2.5);
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

  void _toggleTracking() async {
    setState(() {
      _trackingStarted = !_trackingStarted;
      if (_trackingStarted) {
        _sessionStart = DateTime.now(); // Start time of session
        _distanceTraveled = 0.0;
        _pausedDuration = Duration.zero; // Reset paused duration
        _speeds.clear(); // Clear previous speeds
        _lastTrackedLocation = _currentLocation; // Update last tracked location

        // Start the timer to track elapsed time
        _elapsedSeconds = 0;
        _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedSeconds++;
          });
        });
      } else {
        _sessionEnd = DateTime.now(); // End time of session
        _trackingTimer?.cancel(); // Stop the timer
      }
    });

    if (!_trackingStarted) {
      // If tracking is not started, then we are stopping it and should store the session
      String? userId = await _getUserId(); // This calls the method and waits for the result
      if (userId != null) {
        _storeBikingActivity(userId); // Pass the user ID to the method
      }
    }
  }

  void _recenterMap() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null) {
      controller.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  void _pauseTracking() {
    _positionStreamSubscription?.pause();
    _compassSubscription?.pause();
    _lastPauseTime = DateTime.now(); // Mark the time when paused
    _trackingTimer?.cancel();
  }

  void _resumeTracking() {
    _pausedDuration += DateTime.now().difference(_lastPauseTime); // Accumulate paused duration
    _previousPositionTime = DateTime.now(); // Reset the timer for speed calculation
    _positionStreamSubscription?.resume();
    _compassSubscription?.resume();
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _pauseTracking();
      } else {
        _resumeTracking();
      }
    });
  }

  void _storeBikingActivity(String? userId) {
    if (userId != null && _lastTrackedLocation != null) {
      // Calculate total elapsed time minus any paused time
      int totalElapsedTime = _sessionEnd.difference(_sessionStart).inSeconds - _pausedDuration.inSeconds;

      // Convert distance traveled from meters to miles
      // double distanceTraveledInMiles = _distanceTraveled / 1609.34;

      // Calculate average speed using the speeds list
      double averageSpeedInMph = _speeds.isNotEmpty
          ? _speeds.reduce((a, b) => a + b) / _speeds.length
          : 0.0;
      //this checks if the list is empty before calculating the average speed by summing all the speeds and dividing by the length of the list

      // Store activity in Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('biking_sessions')
          .add({
        'timestamp': DateTime.now(),
        'average_speed': averageSpeedInMph,
        'distance_traveled': _distanceTraveled, //used to be distanceTraveledInMiles
        'time_elapsed': totalElapsedTime, // Store the total elapsed time
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
                  'Speed: ${(_currentSpeed).toStringAsFixed(0)} mph\n'
                      'Distance: ${(_distanceTraveled).toStringAsFixed(2)} mi\n' // used to divide distance traveled like / 1609.34
                      'Time: ${Duration(seconds: _elapsedSeconds).toString().split('.').first}', // Display elapsed time
                ),
              ),
            ),
          if (!_trackingStarted)
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _recenterMap,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.gps_fixed),
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
                  const SizedBox(width: 16), // Add spacing between buttons if needed
                  FloatingActionButton(
                    onPressed: _togglePause,
                    backgroundColor: Colors.orange,
                    // Set the background color to orange
                    child: Icon(
                      _paused ? Icons.restart_alt : Icons.pause,
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