  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart' as LatLng;
  import 'package:geolocator/geolocator.dart';

  class MapPage extends StatefulWidget {
    @override
    _MapPageState createState() => _MapPageState();
  }

  class _MapPageState extends State<MapPage> {
    LatLng.LatLng? _currentLocation;
    MapController mapController = MapController();

    @override
    void initState() {
      super.initState();
      _getLocationPeriodically();
    }

    void _getLocationPeriodically() {
      // Periodically fetch the user's location every 5 seconds
      const duration = Duration(seconds: 5);
      Timer.periodic(duration, (timer) async {
        try {
          Position position = await Geolocator.getCurrentPosition();
          setState(() {
            _currentLocation = LatLng.LatLng(position.latitude, position.longitude);
          });
        } catch (e) {
          print("Error getting location: $e");
        }
      });
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

    void _recenterMap() {
      // Recenter the map to the user's current location
      if (_currentLocation != null) {
        mapController.move(_currentLocation!, 14.0); // Adjust zoom level
      }
    }

    @override
    Widget build(BuildContext context) {
      LatLng.LatLng initialLocation = _currentLocation ?? LatLng.LatLng(34.6275, -84.1935);

      return Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              // GestureDetector to handle map movements
              onPanUpdate: (details) {
                // Update map position based on user's touch movements
                mapController.move(
                      LatLng.LatLng(
                        details.delta.dy / 100,
                        details.delta.dx / 100,
                      ),
                  mapController.zoom,
                );

              },
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: initialLocation,
                  zoom: 14.0, // Adjust initial zoom level
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://api.mapbox.com/styles/v1/kroye01/clrp2zg4o005z01pfcbr00eup/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
                    additionalOptions: {
                      'accessToken':
                      'pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw',
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
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _recenterMap,
                child: Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      );
    }
  }
