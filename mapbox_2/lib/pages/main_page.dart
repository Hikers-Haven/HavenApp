import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mapbox_2/customAppBar.dart';
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