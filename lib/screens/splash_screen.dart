import 'package:flutter/material.dart';
import 'package:beacon/utils/theme.dart';
import 'package:beacon/widgets/beacon_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo widget
            const BeaconLogo(size: 120),
            const SizedBox(height: 24),
            
            // App name
            Text(
              'Beacon',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tagline
            Text(
              'Stay connected, even off the grid',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.darkGrey,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}