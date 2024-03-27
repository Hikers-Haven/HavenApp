import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapService {
  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end, [List<LatLng>? waypoints]) async {
    const String accessToken = 'sk.eyJ1IjoiY29saXBoYW50MDEiLCJhIjoiY2x0eXhmajEyMGp4eDJycGo5MncybXhvdCJ9.nLKWbR2KqwBtf2v-nopBQg';
    String waypointsString = '';
    if (waypoints != null) {
      for (LatLng waypoint in waypoints) {
        waypointsString += '${waypoint.longitude},${waypoint.latitude};';
      }
    }
    // Remove the last semicolon if waypoints are added
    waypointsString = waypointsString.isNotEmpty ? waypointsString.substring(0, waypointsString.length - 1) : '';
    String url = 'https://api.mapbox.com/directions/v5/mapbox/cycling/${start.longitude},${start.latitude};${waypointsString.isNotEmpty ? waypointsString + ';' : ''}${end.longitude},${end.latitude}?geometries=geojson&overview=full&access_token=$accessToken';

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

