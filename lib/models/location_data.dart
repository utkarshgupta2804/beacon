class LocationData {
  final String userId;
  final String username;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double speed;
  final double heading;
  final DateTime timestamp;

  LocationData({
    required this.userId,
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      userId: json['userId'],
      username: json['username'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      altitude: json['altitude'],
      accuracy: json['accuracy'],
      speed: json['speed'],
      heading: json['heading'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}