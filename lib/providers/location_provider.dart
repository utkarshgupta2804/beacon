import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:beacon/models/location_data.dart';

class LocationProvider with ChangeNotifier {
  LocationData? _currentLocation;
  bool _isTracking = false;
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;

  LocationData? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startTracking({String? userId, String? username}) async {
    if (_isTracking) return;

    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }

    try {
      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _updateLocation(position, userId, username);

      // Start listening to position updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _updateLocation(position, userId, username);
      });

      _isTracking = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  void _updateLocation(Position position, String? userId, String? username) {
    _currentLocation = LocationData(
      userId: userId ?? 'unknown',
      username: username ?? 'Unknown User',
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _positionStream?.cancel();
    _positionStream = null;
    
    if (_locationTimer != null) {
      _locationTimer!.cancel();
      _locationTimer = null;
    }

    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}