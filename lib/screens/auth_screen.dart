import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/auth_provider.dart';
import 'package:beacon/utils/theme.dart';
import 'package:beacon/widgets/beacon_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success;

      if (_isLogin) {
        success = await authProvider.signIn(
          _usernameController.text.trim(),
          _passwordController.text,
        );
      } else {
        success = await authProvider.signUp(
          _usernameController.text.trim(),
          _passwordController.text,
          _displayNameController.text.trim(),
        );
      }

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin 
              ? 'Invalid username or password' 
              : 'Failed to create account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const BeaconLogo(size: 80),
                const SizedBox(height: 24),
                
                // App name
                Text(
                  'Beacon',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'Stay connected, even off the grid',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Auth form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Display name field (only for signup)
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a display name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (!_isLogin && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Switch auth mode button
                      TextButton(
                        onPressed: _switchAuthMode,
                        child: Text(
                          _isLogin
                              ? 'Create an account'
                              : 'Already have an account? Sign in',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}