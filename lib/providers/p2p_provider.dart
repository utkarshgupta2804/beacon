import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:beacon/models/message.dart';
import 'package:beacon/models/peer.dart';
import 'package:beacon/models/location_data.dart';
import 'package:uuid/uuid.dart';

class P2PProvider with ChangeNotifier {
  final Nearby _nearby = Nearby();
  final Strategy _strategy = Strategy.P2P_CLUSTER;
  final String _serviceId = 'com.beacon.p2p';
  
  final List<Peer> _connectedPeers = [];
  final List<Peer> _discoveredPeers = [];
  final List<Message> _messages = [];
  
  bool _isHosting = false;
  bool _isDiscovering = false;
  bool _isInitialized = false;
  
  String? _currentUserId;
  String? _currentUsername;
  
  StreamController<Message> _messageStreamController = StreamController<Message>.broadcast();
  Stream<Message> get messageStream => _messageStreamController.stream;
  
  List<Peer> get connectedPeers => [..._connectedPeers];
  List<Peer> get discoveredPeers => [..._discoveredPeers];
  List<Message> get messages => [..._messages];
  bool get isHosting => _isHosting;
  bool get isDiscovering => _isDiscovering;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String userId, String username) async {
    if (_isInitialized) return;
    
    _currentUserId = userId;
    _currentUsername = username;
    
    // Request required permissions
    await _requestPermissions();
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.nearbyWifiDevices,
      ].request();
    } else if (Platform.isIOS) {
      await Permission.location.request();
    }
  }

  Future<bool> startHosting() async {
    if (!_isInitialized || _isHosting) return false;
    
    try {
      bool started = await _nearby.startAdvertising(
        _currentUsername!,
        _strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: _serviceId,
      );
      
      if (started) {
        _isHosting = true;
        notifyListeners();
      }
      
      return started;
    } catch (e) {
      debugPrint('Error starting hosting: $e');
      return false;
    }
  }

  Future<bool> stopHosting() async {
    if (!_isHosting) return true;
    
    try {
      await _nearby.stopAdvertising();
      _isHosting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error stopping hosting: $e');
      return false;
    }
  }

  Future<bool> startDiscovery() async {
    if (!_isInitialized || _isDiscovering) return false;

    try {
      bool started = await _nearby.startDiscovery(
        _currentUsername!,
        _strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: (endpointId) => _onEndpointLost(endpointId!),
        serviceId: _serviceId,
      );

      if (started) {
        _isDiscovering = true;
        _discoveredPeers.clear();
        notifyListeners();
      }

      return started;
    } catch (e) {
      debugPrint('Error starting discovery: $e');
      return false;
    }
  }

  Future<bool> stopDiscovery() async {
    if (!_isDiscovering) return true;
    
    try {
      await _nearby.stopDiscovery();
      _isDiscovering = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error stopping discovery: $e');
      return false;
    }
  }

  Future<bool> connectToPeer(String endpointId) async {
    try {
      await _nearby.requestConnection(
        _currentUsername!,
        endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
      return true;
    } catch (e) {
      debugPrint('Error connecting to peer: $e');
      return false;
    }
  }

  Future<bool> disconnectFromPeer(String endpointId) async {
    try {
      await _nearby.disconnectFromEndpoint(endpointId);
      
      // Remove from connected peers
      _connectedPeers.removeWhere((peer) => peer.id == endpointId);
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error disconnecting from peer: $e');
      return false;
    }
  }

  Future<bool> sendMessage(String peerId, String content, String type) async {
    if (!_isInitialized) return false;
    
    try {
      // Create a message object
      final message = Message(
        id: const Uuid().v4(),
        senderId: _currentUserId!,
        senderName: _currentUsername!,
        content: content,
        type: type,
        timestamp: DateTime.now(),
      );
      
      // Convert to JSON
      final payload = json.encode({
        'type': 'message',
        'data': message.toJson(),
      });
      
      // Send the message
      await _nearby.sendBytesPayload(
        peerId, 
        Uint8List.fromList(utf8.encode(payload)),
      );
      
      // Add to local messages
      _messages.add(message);
      _messageStreamController.add(message);
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  Future<bool> sendLocationUpdate(LocationData locationData) async {
    if (!_isInitialized || _connectedPeers.isEmpty) return false;
    
    try {
      // Convert to JSON
      final payload = json.encode({
        'type': 'location',
        'data': locationData.toJson(),
      });
      
      // Send to all connected peers
      for (final peer in _connectedPeers) {
        await _nearby.sendBytesPayload(
          peer.id, 
          Uint8List.fromList(utf8.encode(payload)),
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Error sending location update: $e');
      return false;
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo connectionInfo) {
    // Auto-accept connections
    _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      // Find the peer in discovered peers
      final peerIndex = _discoveredPeers.indexWhere((p) => p.id == endpointId);
      
      if (peerIndex >= 0) {
        final peer = _discoveredPeers[peerIndex];
        
        // Add to connected peers if not already there
        if (!_connectedPeers.any((p) => p.id == endpointId)) {
          _connectedPeers.add(peer);
        }
        
        // Remove from discovered peers
        _discoveredPeers.removeAt(peerIndex);
      } else {
        // If not found in discovered peers, create a new peer object
        _connectedPeers.add(Peer(
          id: endpointId,
          name: 'Unknown',
          lastSeen: DateTime.now(),
        ));
      }
      
      notifyListeners();
    }
  }

  void _onDisconnected(String endpointId) {
    // Remove from connected peers
    _connectedPeers.removeWhere((peer) => peer.id == endpointId);
    notifyListeners();
  }

  void _onEndpointFound(String endpointId, String endpointName, String serviceId) {
    // Add to discovered peers if not already there
    if (!_discoveredPeers.any((p) => p.id == endpointId) &&
        !_connectedPeers.any((p) => p.id == endpointId)) {
      _discoveredPeers.add(Peer(
        id: endpointId,
        name: endpointName,
        lastSeen: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void _onEndpointLost(String endpointId) { // ✅ Correct parameter type
    // Remove from discovered peers
    _discoveredPeers.removeWhere((peer) => peer.id == endpointId);
    notifyListeners();
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES) {
      final String payloadData = String.fromCharCodes(payload.bytes!);
      final Map<String, dynamic> data = json.decode(payloadData);
      
      final String type = data['type'];
      
      if (type == 'message') {
        final message = Message.fromJson(data['data']);
        _messages.add(message);
        _messageStreamController.add(message);
        notifyListeners();
      } else if (type == 'location') {
        final locationData = LocationData.fromJson(data['data']);
        
        // Update the peer's location
        final peerIndex = _connectedPeers.indexWhere((p) => p.id == endpointId);
        if (peerIndex >= 0) {
          _connectedPeers[peerIndex].lastLocation = locationData;
          _connectedPeers[peerIndex].lastSeen = DateTime.now();
          notifyListeners();
        }
      }
    }
  }

  void _onPayloadTransferUpdate(String endpointId, PayloadTransferUpdate update) {
    // Handle payload transfer updates if needed
  }

  @override
  void dispose() {
    stopHosting();
    stopDiscovery();
    _messageStreamController.close();
    super.dispose();
  }
}