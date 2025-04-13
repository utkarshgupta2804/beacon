import 'dart:math';
import 'package:beacon/models/location_data.dart';

class Peer {
  final String id;
  final String name;
  LocationData? lastLocation;
  DateTime lastSeen;
  bool isActive;

  Peer({
    required this.id,
    required this.name,
    this.lastLocation,
    required this.lastSeen,
    this.isActive = true,
  });

  // Calculate if the peer is considered online (seen in the last 2 minutes)
  bool get isOnline {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    return difference.inMinutes < 2;
  }

  // Calculate distance from current user if both locations are available
  double? distanceFrom(LocationData? myLocation) {
    if (myLocation == null || lastLocation == null) {
      return null;
    }

    // Use Haversine formula to calculate distance
    return _calculateDistance(
      myLocation.latitude,
      myLocation.longitude,
      lastLocation!.latitude,
      lastLocation!.longitude,
    );
  }

  // Haversine formula to calculate distance between two points on Earth
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // in meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = 
        pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        pow(sin(dLon / 2), 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
