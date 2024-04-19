import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle, SystemChannels;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// StatefulWidget to handle the dynamic nature of a map page where user interaction causes changes.
class MapPage extends StatefulWidget {
  static final GlobalKey<_MapPageState> mapKey = GlobalKey<_MapPageState>();

  MapPage({Key? key}) : super(key: mapKey);  // Ensure key initialization is correct.

  @override
  _MapPageState createState() => _MapPageState();
}



// State class for MapPage, includes location and map tracking functionalities.
class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  // Controller for GoogleMap, allows for map interactions.
  Completer<GoogleMapController> _controller = Completer();

  // Sets to keep track of lines (routes) and markers on the map.
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  // Current location of the user as a LatLng object.
  LatLng? _currentLocation;

  // Subscriptions to position and compass event streams.
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Tracking variables for navigation.
  double _lastBearing = 0.0;
  double _currentSpeed = 0.0;
  bool _trackingStarted = false;
  bool _paused = false;
  double _distanceTraveled = 0.0;
  LatLng? _lastTrackedLocation;

  // Custom styling for the map.
  String _mapStyle = "assets/map_style.json";

  // Unique key for the map widget to force re-rendering.
  Key _mapKey = UniqueKey();

  // Timer for tracking movement over time.
  Timer? _trackingTimer;
  int _elapsedSeconds = 0;
  DateTime? _previousPositionTime;

  // Timestamps to manage session start and end.
  late DateTime _sessionStart;
  late DateTime _sessionEnd;
  Duration _pausedDuration = Duration.zero;
  late DateTime _lastPauseTime;

  // Queue to keep track of speed measurements.
  final Queue<double> _speeds = Queue<double>();

  // Constants for distance and speed limits.
  double maxDistancePerSecond = 15.0;
  double plausibleSpeedLimit = 30.0;

  // Icons for custom markers on the map.
  BitmapDescriptor? waterSpotIcon; // ? means it can be null
  BitmapDescriptor? repairStationIcon; // ? means it can be null

  @override
  void initState() {
    super.initState();
    // Add the current state as an observer to changes in the widget's lifecycle.
    WidgetsBinding.instance.addObserver(this);
    // Initialize location services and listeners for device compass and position.
    _initLocationService();
    _startCompassListener();
    // Load assets and data necessary for the map.
    _loadAssetsAndData();
    // Fetch the current location after the frame callback to ensure everything is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  void updateMapWithLocation(double latitude, double longitude) {
    if (_controller.isCompleted) {
      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
      });
    }
  }
  bool trackingIsActive() {
    return _trackingStarted && !_paused;
  }


  Future<void> _loadAssetsAndData() async {
    // Load custom icons for water spots and repair stations.
    await _loadCustomIcon();
    // Load the custom style for the map from assets.
    await _loadMapStyle();
    // Load trail data to display on the map.
    await _loadTrailData();
    // Load data for water spots and repair stations to add as markers.
    _loadWaterSpots();
    _loadRepairStations();
  }

  void _showWalkthrough() {
    // Displays an informative dialog about map functionalities.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Map Walkthrough'),
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to the map! Here you can see your current location, '
                    'track your biking sessions, view water spots and repair stations, '
                    'and much more. Use the play button to start tracking your biking '
                    'session, and the pause button to pause/resume. You can also click '
                    'on the GPS icon to recenter the map on your current location. '
                    'Enjoy your biking experience!',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Got It!'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCustomIcon() async {
    // Asynchronously load custom icons from assets with a specified configuration.
    waterSpotIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/waterenergy.png');
    repairStationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/servicestation.png');
  }

  Future<void> _loadMapStyle() async {
    // Load a custom JSON style for the Google map from the assets.
    _mapStyle = await rootBundle.loadString("assets/map_style.json");
    // Trigger a rebuild of the state to apply the new map style.
    setState(() {});
  }

  @override
  void dispose() {
    // Remove this object from the list of observers and cancel all subscriptions. Because the map page is no longer active.
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel(); // if the subscription is active and not null, cancel it.
    _compassSubscription?.cancel(); // if the compass subscription is active and not null, cancel it.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle changes in the app's lifecycle state, such as pausing or resuming.
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reset the map controller and fetch the current location when the app is resumed.
      setState(() {
        _controller = Completer();
        _getCurrentLocation();
        _mapKey = UniqueKey();  // Refresh the map with a new key.
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    // Attempt to fetch the current geographic location of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current Location: ${position.latitude}, ${position.longitude}');
      // Update the map location to reflect the new position.
      _updateLocation(position);
    } on PermissionDeniedException {
      print('Location permissions are denied');
    } on LocationServiceDisabledException {
      print('Location services are disabled');
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  void _updateMapWithLocation(double latitude, double longitude) {
    // Update the map with the new location
    if (_controller.isCompleted) {
      _controller.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
      });
    }
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMarker(position);
    });
    if (!_paused) {
      _moveCameraToCurrentLocation();
    }
  }


  // void _initLocationService() async {
  //   // Initialize location services and handle permissions.
  //   try {
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); // Check if location services are enabled.
  //     if (!serviceEnabled) {
  //       throw 'Location services are disabled.';
  //     }
  //
  //     LocationPermission permission = await Geolocator.checkPermission(); // Check the current location permission.
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
  //         if (mounted) { // Check if the widget is still mounted before showing a dialog. (mounted means it's still active)
  //           await showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: const Text('Location Permission Required'),
  //                 content: const Text(
  //                     'This app needs location permissions to function. Please grant location permission.'),
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
  //     // Subscribe to position updates based on the specified location settings. Meaning, the app will receive updates when the user moves.
  //     _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
  //         .listen((Position position) {
  //       if (_paused) return;  // Do not update if tracking is paused.
  //       if (position.accuracy > 50) return;  // Skip updates with low accuracy. (Avoids noise)
  //
  //       final LatLng newLocation = LatLng(position.latitude, position.longitude); // Convert the new position to a LatLng object.
  //       // Calculate the distance moved since the last update.
  //       if (_lastTrackedLocation != null) { // If there was a previous location. (Not the first update)
  //         final double distanceMeters = Geolocator.distanceBetween( // Calculate the distance between the last and new locations.
  //             _lastTrackedLocation!.latitude,
  //             _lastTrackedLocation!.longitude,
  //             newLocation.latitude,
  //             newLocation.longitude);
  //
  //         if (distanceMeters < 3.0) return;  // Ignore minor movements. (Less than 3 meters to avoid noise)
  //
  //         final DateTime currentTime = DateTime.now(); // Get the current time.
  //         int timeDifferenceInSeconds;
  //         if (_previousPositionTime != null) { // Calculate the time difference between the current and previous updates.
  //           timeDifferenceInSeconds = currentTime.difference(_previousPositionTime!).inSeconds;
  //         } else {
  //           timeDifferenceInSeconds = 0;
  //         }
  //
  //
  //         if (distanceMeters > 15.0 * timeDifferenceInSeconds) { // Check if the distance moved is plausible and not too large. (15 meters per second is the limit)
  //           return;  // Ignore improbable large distances in a short time.
  //         }
  //
  //         double speedInMph = position.speed * 2.23694;  // Convert speed to miles per hour.
  //         updateSpeed(speedInMph);
  //
  //         if (timeDifferenceInSeconds >= 2) { // Update the distance traveled if at least 2 seconds have passed.
  //           final double distanceMiles = distanceMeters * 0.000621371;
  //           updateDistance(distanceMiles);
  //         }
  //
  //         _previousPositionTime = currentTime; // Update the previous time and location for the next iteration.
  //         _lastTrackedLocation = newLocation; // Update the last tracked location.
  //       } else {
  //         _lastTrackedLocation = newLocation; // Set the last tracked location to the new location if it's the first update.
  //         _previousPositionTime = DateTime.now(); // Set the previous time to the current time.
  //       }
  //
  //       if (!_controller.isCompleted) { // Move the map camera to the current location if the map is ready.
  //         _moveCameraToCurrentLocation(); // Move the camera to the current location.
  //       }
  //     });
  //   } catch (e) {
  //     print('Error initializing location service: $e');
  //   }
  // }

  void _initLocationService() async {
    // Initialize location services and handle permissions.
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); // Check if location services are enabled.
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission(); // Check the current location permission.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text(
                      'This app needs location permissions to function. Please grant location permission.'),
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

      _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        if (_paused) return; // Do not process updates if tracking is paused.

        final LatLng newLocation = LatLng(position.latitude, position.longitude);
        final DateTime currentTime = DateTime.now();
        int timeDifferenceInSeconds = _previousPositionTime != null ? currentTime.difference(_previousPositionTime!).inSeconds : 0;

        double distanceMeters = Geolocator.distanceBetween(
            _lastTrackedLocation?.latitude ?? 0,
            _lastTrackedLocation?.longitude ?? 0,
            newLocation.latitude,
            newLocation.longitude);

        if (distanceMeters > 15.0 * timeDifferenceInSeconds) { // Ignore large implausible moves.
          return;
        }

        if (timeDifferenceInSeconds >= 2) {
          double distanceMiles = distanceMeters * 0.000621371;
          updateDistance(distanceMiles);
        }

        double speedInMph = position.speed * 2.23694; // Convert speed to mph.
        updateSpeed(speedInMph);

        _previousPositionTime = currentTime;
        _lastTrackedLocation = newLocation;

        _updateLocation(position); // Update the current location and UI but not necessarily the camera position.

        if (!_paused && _controller.isCompleted) { // Only auto-center if not paused and controller is ready.
          _moveCameraToCurrentLocation();
        }
      });
    } catch (e) {
      print('Error initializing location service: $e');
    }
  }


  void updateDistance(double newDistance) {
    // Increment the distance traveled by the new distance calculated.
    _distanceTraveled += newDistance;
    // Update the UI to reflect changes.
    setState(() {}); // Trigger a rebuild of the widget.
  }

  void updateSpeed(double newSpeed) {
    // Check if the new speed is within plausible limits before updating.
    if (newSpeed <= plausibleSpeedLimit) { // Ignore speeds that are too high.
      if (_speeds.length >= 100) { // Limit the number of speed readings to 100.
        _speeds.removeFirst();  // Remove the oldest speed reading.
      }
      _speeds.add(newSpeed); // Add the new speed to the queue.
    }


    setState(() { // Trigger a rebuild of the widget.
      _currentSpeed = newSpeed; // Update the current speed.
    });
  }

  // void _moveCameraToCurrentLocation() async {
  //   // Move the map camera to the current location if the map is ready.
  //   if (!_controller.isCompleted || _trackingStarted) return; // Do not move the camera if tracking is active.
  //   final GoogleMapController controller = await _controller.future; // Get the map controller.
  //   if (_currentLocation != null) { // Check if the current location is available.
  //     controller.animateCamera(CameraUpdate.newLatLngZoom( // Move the camera to the current location.
  //         _currentLocation!, 15));
  //   }
  // }

  void _moveCameraToCurrentLocation() async {
    // Only move the camera if the controller is ready and neither tracking is active nor paused.
    if (!_controller.isCompleted || _paused || _trackingStarted) return;

    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(
          _currentLocation!, 14));
    }
  }



  Future<void> _loadTrailData() async {
    // Load geographical data for trails from assets.
    try {
      final String geoJsonString =
      await rootBundle.loadString('assets/geodata.json'); // Load the geo data from the assets (geodata.json).
      final data = json.decode(geoJsonString); // Decode the JSON data into a Map object called data.

      _polylines.clear(); // Clear the existing polylines and markers.
      _markers.clear();  // Clear the existing markers.

      print("Total features found: ${data['features'].length}");

      for (var feature in data['features']) { // Iterate over each feature in the data.
        if (feature['geometry']['type'] == "LineString") {
          List<dynamic> coordinatesList = feature['geometry']['coordinates'] as List;
          List<LatLng> lineCoordinates = [];

          // Convert each coordinate pair into a LatLng object
          for (var coord in coordinatesList) {
            LatLng latLng = LatLng(coord[1], coord[0]);
            lineCoordinates.add(latLng);
          }

          print("Adding polyline: ${feature['properties']['name']} with points: ${lineCoordinates.length}");

          _polylines.add(Polyline( // Add a new polyline to the set of polylines. This represents a trail on the map.
            polylineId: PolylineId(feature['properties']['name']),
            points: lineCoordinates,
            color: Colors.blue,
            width: 3,
          ));
        }
      }


      // Trigger a UI update to show the new trails on the map.
      setState(() {}); // Rebuild the widget to reflect the new data.
    } catch (e) {
      print('Failed to load geo data: $e');
    }
  }



  Future<void> _loadWaterSpots() async {
    // Attempt to load water spot data from a JSON file.
    try {
      final String waterStationsJsonString = await rootBundle.loadString('assets/waterspots.json');
      // Decode the JSON string into a list of maps.
      List<dynamic> waterStations = json.decode(waterStationsJsonString);

      if (waterSpotIcon == null) {
        print("Water spot icon is not loaded");
        return; // Exit if the icon is not loaded.
      }

      // Update the UI with the new markers.
      setState(() {
        for (var station in waterStations) {
          // Convert each station's data into a marker.
          Marker newMarker = Marker(
            markerId: MarkerId(station['name']),
            position: LatLng(station['lat'], station['lng']),
            icon: waterSpotIcon!, // Ensure the icon is not null.
          );
          _markers.add(newMarker); // Add the new marker to the set.
        }
      });

      // Log the total number of markers loaded.
      print("Water spots loaded with icons. Total markers: ${_markers.length}");
    } catch (e) {
      // Handle any errors during JSON loading or marker creation.
      print('Failed to load water spots or icons: $e');
    }
  }



  Future<void> _loadRepairStations() async {
    // Attempt to load repair station data from a JSON file.
    try {
      final String repairStationsJsonString = await rootBundle.loadString('assets/repairstations.json');
      // Decode the JSON string into a list of dynamic objects.
      List<dynamic> repairStations = json.decode(repairStationsJsonString);

      if (repairStationIcon == null) { // Ensure the repair station icon is loaded.
        print("Repair station icon is not loaded");
        return; // Exit if the icon is not loaded.
      }

      // Update the UI state with new markers.
      setState(() {
        for (var station in repairStations) {
          // Convert each station's data into a marker.
          Marker newMarker = Marker(
            markerId: MarkerId(station['name']),
            position: LatLng(station['lat'], station['lng']),
            icon: repairStationIcon!, // Ensure the icon is not null.
          );
          _markers.add(newMarker); // Add the new marker to the set.
        }
      });

      // Log the total number of markers loaded.
      print("Repair stations loaded with icons. Total markers: ${_markers.length}");
    } catch (e) {
      // Handle any errors during JSON loading or marker creation.
      print('Failed to load repair stations or icons: $e');
    }
  }


  Future<String?> _getUserId() async { // Get the unique user ID for the current Firebase user.
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<BitmapDescriptor> _createMarkerImageFromAsset(String assetName) async {
    // Load a custom image from assets to be used as a map marker icon.
    const ImageConfiguration imageConfiguration =
    ImageConfiguration(devicePixelRatio: 2.5);
    BitmapDescriptor bitmapDescriptor = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      assetName,
    );
    return bitmapDescriptor;
  }

  void _updateMarker(Position position) async {
    // Update the location marker on the map to reflect the current position.
    for (int i = 0; i < _markers.length; i++) {
      if (_markers.elementAt(i).markerId == const MarkerId("currentLocation")) {
        _markers.remove(_markers.elementAt(i));
        break; // Exit the loop once the marker is found and removed.
      }
    }

    // Load a custom icon for the current location marker.
    BitmapDescriptor icon = await _createMarkerImageFromAsset('assets/navicon.png');
    Marker newMarker = Marker(
        markerId: const MarkerId("currentLocation"),
        position: LatLng(position.latitude, position.longitude),
        icon: icon
    );
    _markers.add(newMarker); // Add the new current location marker.

    // Reload data for water spots and repair stations to ensure they are current.
    await _loadWaterSpots(); // Load water spots and update icons.
    await _loadRepairStations(); // Load repair stations and update icons.

    // Update the UI to reflect the new marker positions.
    setState(() {});
  }


  void _startCompassListener() { // Start listening to compass events to get the current direction.
    _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) { // assert that the FlutterCompass.events is not null. and listen to the compass events.
      final double? direction = event.heading; // Get the current heading from the event.
      if (direction != null) {
        setState(() {
          _lastBearing = direction;  // Update the bearing based on the compass direction.
        });
        if (_trackingStarted) {
          _updateMapBearing();  // Adjust the map's view to align with the new bearing.
        }
      }
    });
  }

  void _updateMapBearing() async {
    // Rotate the map to align with the current bearing only if tracking is active and not paused.
    if (!_controller.isCompleted || _paused || !_trackingStarted) return; // Do not update if the map controller is not ready or tracking is paused.

    final GoogleMapController controller = await _controller.future;  // Get the map controller.
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _currentLocation!, // Move the camera to the current location.
      bearing: _lastBearing, // Rotate the camera to align with the current bearing.
      zoom: 16.0,
    )));
  }


  void _toggleTracking() async {
    // Start or stop tracking the user's movement.
    setState(() {
      _trackingStarted = !_trackingStarted; // Toggle the tracking state.

      if (_trackingStarted) {
        _paused = false;  // Reset the pause state.
        // Start a new tracking session.
        _sessionStart = DateTime.now();
        _distanceTraveled = 0.0;
        _pausedDuration = Duration.zero;
        _speeds.clear();
        _lastTrackedLocation = _currentLocation;
        _startCompassListener();
        _elapsedSeconds = 0;
        _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedSeconds++;  // Update the elapsed time for the session.
          });
        });
      } else {
        // End the current tracking session.
        _sessionEnd = DateTime.now();
        _trackingTimer?.cancel();
        _compassSubscription?.cancel();

        _paused = false;  // Reset the pause state.
      }
    });

    if (!_trackingStarted) {
      // Store the session data if tracking was stopped.
      String? userId = await _getUserId(); //String? means it can be null
      if (userId != null) {
        _storeBikingActivity(userId);
      }
    }
  }

  void _recenterMap() async {
    // Recenter the map on the current location.
    final GoogleMapController controller = await _controller.future;
    if (_currentLocation != null) {
      controller.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    }
  }

  // using ?. operator to access the compass subscription only if it is not null.
  // using ?? operator to provide a default value of 0.0 if the _currentSpeed is null.
  // using !. operator to assert that the _currentLocation is not null.
  void _pauseTracking() {
    // Pause the tracking of the user's movement.
    _positionStreamSubscription?.pause(); //access the position stream subscription only if it is not null and pause it.
    _compassSubscription?.pause(); //access the compass subscription only if it is not null and pause it.
    _lastPauseTime = DateTime.now();  // Record the time when tracking was paused.
    _trackingTimer?.cancel();  // Stop the timer.
  }

  void _resumeTracking() {
    // Resume tracking after a pause.
    _pausedDuration += DateTime.now().difference(_lastPauseTime); // Calculate the total paused duration.
    _previousPositionTime = DateTime.now(); // Reset the timer for speed calculation.
    _positionStreamSubscription?.resume(); // Resume listening to position updates.
    _compassSubscription?.resume(); // Resume listening to compass events.
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++; // Update the elapsed time since resuming.
      });
    });
  }

  void _togglePause() {
    // Toggle the paused state of tracking.
    setState(() {
      if(_trackingStarted) { // Only pause if tracking is active (not stopped).
        _paused = !_paused; // Toggle the paused state.
        if (_paused) {
          _pauseTracking(); // Pause tracking if it was not paused.
        } else {
          _resumeTracking(); // Resume tracking if it was paused.
        }
      }
      // _paused = !_paused;
      // if (_paused) {
      //   _pauseTracking();
      // } else {
      //   _resumeTracking();
      // }
    });
  }

  Future<void> updatePersonalBest(String userId, double newSpeed, double newDistance, int newDuration) async {
    // Update the user's personal best records for speed, distance, and duration.
    DocumentReference personalBestDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('personal_best')
        .doc('personalbestdoc');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(personalBestDoc);

      if (!snapshot.exists) {
        // If there is no existing record, create a new one.
        transaction.set(personalBestDoc, {
          'fastest_speed': newSpeed,
          'longest_distance': newDistance,
          'longest_duration': newDuration,
        });
        return;
      }
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      double currentFastestSpeed = data['fastest_speed'] ?? 0.0;
      double currentLongestDistance = data['longest_distance'] ?? 0.0;
      int currentLongestDuration = data['longest_duration'] ?? 0;

      Map<String, dynamic> updates = {};
      if (newSpeed > currentFastestSpeed) {
        updates['fastest_speed'] = newSpeed;
      }
      if (newDistance > currentLongestDistance) {
        updates['longest_distance'] = newDistance;
      }
      if (newDuration > currentLongestDuration) {
        updates['longest_duration'] = newDuration;
      }

      if (updates.isNotEmpty) {
        transaction.update(personalBestDoc, updates);
      }
    });
  }
  void _storeBikingActivity(String? userId) async {
    // Store the session data in Firestore under the user's document.
    if (userId != null && _lastTrackedLocation != null) {
      int totalElapsedTime = _sessionEnd.difference(_sessionStart).inSeconds -
          _pausedDuration.inSeconds;

      double averageSpeedInMph;
      if (_speeds.isNotEmpty) {
        double totalSpeed = 0.0;
        for (double speed in _speeds) {
          totalSpeed += speed;
        }
        averageSpeedInMph = totalSpeed / _speeds.length;
      } else {
        averageSpeedInMph = 0.0;
      }


      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('biking_sessions')
          .add({
        'timestamp': DateTime.now(),
        'average_speed': averageSpeedInMph,
        'distance_traveled': _distanceTraveled,
        'time_elapsed': totalElapsedTime / 60,
      }).then((_) {
        print('Biking activity stored successfully');
      }).catchError((error) {
        print('Failed to store biking activity: $error');
      });
      updatePersonalBest(userId, averageSpeedInMph, _distanceTraveled, totalElapsedTime);

    }

  }

  @override
  Widget build(BuildContext context) {
    // Build the user interface for the map page.
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: _mapKey,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(41.754469456020566, -88.34949396560636,), // Center the map on the current location if available. Otherwise, center on AU.
              zoom: 14.0,
            ),
            style: _mapStyle,
            // Apply loaded style
            polylines: _polylines,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              if (_currentLocation != null) {
                controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 16));
              }
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
                      'Distance: ${(_distanceTraveled).toStringAsFixed(2)} mi\n'
                      'Time: ${Duration(seconds: _elapsedSeconds).toString().split('.').first}',
                ),
              ),
            ),
          if (!_trackingStarted)
            // Positioned(
            //   top: 20,
            //   right: 20,
            //   child: FloatingActionButton(
            //     onPressed: _recenterMap,
            //     backgroundColor: Colors.blue,
            //     child: const Icon(Icons.gps_fixed),
            //   ),
            // ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _moveCameraToCurrentLocation,  // This triggers moving the camera.
                backgroundColor: Colors.blue,
                child: const Icon(Icons.gps_fixed),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
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
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: _togglePause,
                    backgroundColor: Colors.orange,
                    child: Icon(
                      _paused ? Icons.restart_alt : Icons.pause,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 20,
            child: !_trackingStarted
                ? FloatingActionButton(
              onPressed: _showWalkthrough,
              backgroundColor: Colors.grey,
              child: const Icon(Icons.help_outline),
            ) : SizedBox(),
          ),
        ],
      ),
    );
  }
}
