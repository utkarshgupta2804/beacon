import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/auth_provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/providers/location_provider.dart';
import 'package:beacon/screens/map_screen.dart';
import 'package:beacon/screens/chat_screen.dart';
import 'package:beacon/screens/peers_screen.dart';
import 'package:beacon/screens/settings_screen.dart';
import 'package:beacon/utils/theme.dart';
import 'package:beacon/widgets/beacon_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isInitializing = true;
  bool _isNetworkActive = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final p2pProvider = Provider.of<P2PProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Initialize P2P provider
    await p2pProvider.initialize(
      authProvider.userId!,
      authProvider.displayName ?? authProvider.username!,
    );

    // Check location permissions
    await locationProvider.checkPermissions();

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _toggleNetwork() async {
    final p2pProvider = Provider.of<P2PProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_isNetworkActive) {
      // Stop network
      await p2pProvider.stopHosting();
      await p2pProvider.stopDiscovery();
      await locationProvider.stopTracking();
      
      setState(() {
        _isNetworkActive = false;
      });
    } else {
      // Start network
      final hostingStarted = await p2pProvider.startHosting();
      final discoveryStarted = await p2pProvider.startDiscovery();
      
      if (hostingStarted && discoveryStarted) {
        try {
          await locationProvider.startTracking(
            userId: authProvider.userId,
            username: authProvider.displayName ?? authProvider.username,
          );
          
          setState(() {
            _isNetworkActive = true;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start location tracking'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start P2P network'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const MapScreen(),
      const PeersScreen(),
      const ChatScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BeaconLogo(size: 24),
            const SizedBox(width: 8),
            Text(
              'Beacon',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isInitializing)
            Switch(
              value: _isNetworkActive,
              onChanged: (value) => _toggleNetwork(),
              activeColor: AppTheme.primaryColor,
              activeTrackColor: AppTheme.primaryColor.withOpacity(0.5),
            ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.darkGrey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Peers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}