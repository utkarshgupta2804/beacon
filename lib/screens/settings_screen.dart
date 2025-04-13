import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/auth_provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/providers/location_provider.dart';
import 'package:beacon/utils/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  final _displayNameController = TextEditingController();
  bool _isEditingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _initDisplayName();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  void _initDisplayName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _displayNameController.text = authProvider.displayName ?? '';
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_displayNameController.text.trim().isNotEmpty) {
      await authProvider.updateProfile(_displayNameController.text.trim());
      
      setState(() {
        _isEditingProfile = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final p2pProvider = Provider.of<P2PProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Stop all services
    await p2pProvider.stopHosting();
    await p2pProvider.stopDiscovery();
    await locationProvider.stopTracking();
    
    // Sign out
    await authProvider.signOut();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isEditingProfile) ...[
                    // Edit profile form
                    TextField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditingProfile = false;
                              _displayNameController.text = authProvider.displayName ?? '';
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Profile info
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          authProvider.displayName != null && authProvider.displayName!.isNotEmpty
                              ? authProvider.displayName![0].toUpperCase()
                              : authProvider.username != null && authProvider.username!.isNotEmpty
                                  ? authProvider.username![0].toUpperCase()
                                  : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        authProvider.displayName ?? 'No display name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(authProvider.username ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditingProfile = true;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // App settings
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Location permissions
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: const Text('Location Permissions'),
                    subtitle: const Text('Allow Beacon to access your location'),
                    value: Provider.of<LocationProvider>(context).isTracking,
                    onChanged: (value) async {
                      final locationProvider = Provider.of<LocationProvider>(
                        context,
                        listen: false,
                      );
                      
                      if (value) {
                        final hasPermission = await locationProvider.checkPermissions();
                        if (hasPermission) {
                          await locationProvider.startTracking(
                            userId: authProvider.userId,
                            username: authProvider.displayName ?? authProvider.username,
                          );
                        }
                      } else {
                        await locationProvider.stopTracking();
                      }
                    },
                  ),
                  
                  const Divider(),
                  
                  // Notifications
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: true, // This would be connected to a real setting in production
                    onChanged: (value) {
                      // Implement notification settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification settings coming soon'),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(),
                  
                  // Dark mode
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme'),
                    value: false, // This would be connected to a theme provider in production
                    onChanged: (value) {
                      // Implement dark mode toggle
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dark mode coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // About section
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: const Text('Version'),
                    subtitle: Text(_appVersion),
                  ),
                  
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Open privacy policy
                    },
                  ),
                  
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Open terms of service
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Sign out button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _signOut();
                        },
                        child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}