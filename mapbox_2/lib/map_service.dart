// Import necessary packages
// Import necessary packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapService {
  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    const String accessToken = 'pk.eyJ1Ijoia3JveWUwMSIsImEiOiJjbHJwM2lsZjAwMW1rMnFvZHk5Y2lucHRrIn0.mDHtkPy7Jpz6wkNBrEzfgw';
    // Adjusted URL with `geometries=geojson` and `overview=full`
    final String url = 'https://api.mapbox.com/directions/v5/mapbox/cycling/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full&access_token=$accessToken';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final coordinates = jsonResponse['routes'][0]['geometry']['coordinates'];
      List<LatLng> routePoints = coordinates.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
      return routePoints;
    } else {
      throw Exception('Failed to load route: ${response.body}');
    }
  }
}


