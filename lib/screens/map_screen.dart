import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:beacon/providers/location_provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/utils/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _isFollowingUser = true;

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final p2pProvider = Provider.of<P2PProvider>(context);

    final currentLocation = locationProvider.currentLocation;
    final connectedPeers = p2pProvider.connectedPeers;

    // Center map on current location if available and following is enabled
    if (currentLocation != null && _isFollowingUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(currentLocation.latitude, currentLocation.longitude),
          _mapController.camera.zoom, // Use camera.zoom instead
        );
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocation != null
                  ? LatLng(currentLocation.latitude, currentLocation.longitude)
                  : const LatLng(0, 0),
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _isFollowingUser = false;
                  });
                }
              },
            ),
            children: [
              // Base map layer
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.beacon.app',
              ),

              // Markers layer
              MarkerLayer(
                markers: [
                  // Current user marker
                  if (currentLocation != null)
                    Marker(
                      width: 60.0,
                      height: 60.0,
                      point: LatLng(
                        currentLocation.latitude,
                        currentLocation.longitude,
                      ),
                      child: const _UserMarker(
                        isCurrentUser: true,
                        userName: 'You',
                      ),
                    ),

                  // Connected peers markers
                  ...connectedPeers
                      .where((peer) => peer.lastLocation != null)
                      .map(
                        (peer) => Marker(
                      width: 60.0,
                      height: 60.0,
                      point: LatLng(
                        peer.lastLocation!.latitude,
                        peer.lastLocation!.longitude,
                      ),
                      child: _UserMarker(
                        isCurrentUser: false,
                        userName: peer.name,
                      ),
                    ),
                  )
                      .toList(),
                ],
              ),
            ],
          ),

          // Map controls
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                // Center on user button
                FloatingActionButton(
                  heroTag: 'centerOnUser',
                  mini: true,
                  backgroundColor:
                  _isFollowingUser ? AppTheme.primaryColor : Colors.white,
                  foregroundColor:
                  _isFollowingUser ? Colors.white : AppTheme.primaryColor,
                  onPressed: () {
                    if (currentLocation != null) {
                      _mapController.move(
                        LatLng(
                          currentLocation.latitude,
                          currentLocation.longitude,
                        ),
                        _mapController.camera.zoom, // Use camera.zoom here
                      );
                      setState(() {
                        _isFollowingUser = true;
                      });
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),

                const SizedBox(height: 8),

                // Zoom in button
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1, // Use camera.zoom here
                    );
                  },
                  child: const Icon(Icons.add),
                ),

                const SizedBox(height: 8),

                // Zoom out button
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1, // Use camera.zoom here
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // No location message
          if (currentLocation == null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_off,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Location not available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enable location services and activate the network',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final locationProvider = Provider.of<LocationProvider>(
                          context,
                          listen: false,
                        );
                        await locationProvider.checkPermissions();
                      },
                      child: const Text('Check Permissions'),
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

class _UserMarker extends StatelessWidget {
  final bool isCurrentUser;
  final String? userName;

  const _UserMarker({
    Key? key,
    required this.isCurrentUser,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // User name label
        if (userName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              userName!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? AppTheme.primaryColor : Colors.blue,
              ),
            ),
          ),

        const SizedBox(height: 4),

        // Marker icon
        Container(
          decoration: BoxDecoration(
            color: isCurrentUser ? AppTheme.primaryColor : Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            isCurrentUser ? Icons.person : Icons.person_outline,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }
}