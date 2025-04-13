import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  String? _userId;
  String? _username;
  String? _displayName;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;
  String? get userId => _userId;
  String? get username => _username;
  String? get displayName => _displayName;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    
    if (userData != null) {
      final extractedUserData = json.decode(userData) as Map<String, dynamic>;
      _userId = extractedUserData['userId'];
      _username = extractedUserData['username'];
      _displayName = extractedUserData['displayName'];
      _isAuthenticated = true;
    }
    
    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> signUp(String username, String password, String displayName) async {
    try {
      // In a real app, you would make an API call to create a user
      // For this demo, we'll simulate user creation locally
      
      // Hash the password (never store plain text passwords)
      final passwordBytes = utf8.encode(password);
      final passwordHash = sha256.convert(passwordBytes).toString();
      
      // Generate a unique user ID
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Store user data
      final userData = {
        'userId': userId,
        'username': username,
        'displayName': displayName,
        'passwordHash': passwordHash,
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(userData));
      
      // Update state
      _userId = userId;
      _username = username;
      _displayName = displayName;
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> signIn(String username, String password) async {
    try {
      // In a real app, you would make an API call to authenticate
      // For this demo, we'll simulate authentication locally
      
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      
      if (userData == null) {
        return false;
      }
      
      final extractedUserData = json.decode(userData) as Map<String, dynamic>;
      
      // Hash the provided password
      final passwordBytes = utf8.encode(password);
      final passwordHash = sha256.convert(passwordBytes).toString();
      
      // Check if username and password match
      if (extractedUserData['username'] == username && 
          extractedUserData['passwordHash'] == passwordHash) {
        
        // Update state
        _userId = extractedUserData['userId'];
        _username = extractedUserData['username'];
        _displayName = extractedUserData['displayName'];
        _isAuthenticated = true;
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _userId = null;
    _username = null;
    _displayName = null;
    
    // Clear stored user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    
    notifyListeners();
  }

  Future<void> updateProfile(String displayName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('userData');
      
      if (userData != null) {
        final extractedUserData = json.decode(userData) as Map<String, dynamic>;
        extractedUserData['displayName'] = displayName;
        
        await prefs.setString('userData', json.encode(extractedUserData));
        
        _displayName = displayName;
        notifyListeners();
      }
    } catch (error) {
      // Handle error
    }
  }
}