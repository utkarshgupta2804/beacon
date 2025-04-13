import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/providers/location_provider.dart';
import 'package:beacon/utils/theme.dart';
import 'package:beacon/screens/chat_detail_screen.dart';

class PeersScreen extends StatefulWidget {
  const PeersScreen({Key? key}) : super(key: key);

  @override
  State<PeersScreen> createState() => _PeersScreenState();
}

class _PeersScreenState extends State<PeersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.darkGrey,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: 'Connected'),
                Tab(text: 'Nearby'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ConnectedPeersTab(),
                _NearbyPeersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedPeersTab extends StatelessWidget {
  const _ConnectedPeersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p2pProvider = Provider.of<P2PProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    
    final connectedPeers = p2pProvider.connectedPeers;
    final currentLocation = locationProvider.currentLocation;
    
    if (connectedPeers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No connected peers',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Activate the network to connect with nearby users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: connectedPeers.length,
      itemBuilder: (context, index) {
        final peer = connectedPeers[index];
        final distance = peer.distanceFrom(currentLocation);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(peer.name),
            subtitle: Text(
              distance != null
                  ? 'Distance: ${_formatDistance(distance)}'
                  : 'Location unknown',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chat button
                IconButton(
                  icon: const Icon(Icons.chat, color: AppTheme.primaryColor),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(peer: peer),
                      ),
                    );
                  },
                ),
                
                // Disconnect button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _showDisconnectDialog(context, peer);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  Future<void> _showDisconnectDialog(BuildContext context, peer) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect'),
        content: Text('Disconnect from ${peer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final p2pProvider = Provider.of<P2PProvider>(
                context,
                listen: false,
              );
              p2pProvider.disconnectFromPeer(peer.id);
              Navigator.pop(context);
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NearbyPeersTab extends StatelessWidget {
  const _NearbyPeersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p2pProvider = Provider.of<P2PProvider>(context);
    final discoveredPeers = p2pProvider.discoveredPeers;
    
    if (!p2pProvider.isDiscovering) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_find,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'Discovery not active',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Activate the network to discover nearby users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      );
    }
    
    if (discoveredPeers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No peers discovered',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Searching for nearby users...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: discoveredPeers.length,
      itemBuilder: (context, index) {
        final peer = discoveredPeers[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(peer.name),
            subtitle: Text('Discovered ${_formatTimeDifference(peer.lastSeen)}'),
            trailing: ElevatedButton(
              onPressed: () {
                final p2pProvider = Provider.of<P2PProvider>(
                  context,
                  listen: false,
                );
                p2pProvider.connectToPeer(peer.id);
              },
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  String _formatTimeDifference(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}