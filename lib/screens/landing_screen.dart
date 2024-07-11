import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'package:rental_management/screens/property_listing.dart';

import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    bool isSignedIn = await authProvider.checkAuthenticationState();

    // Delay for 2 seconds before navigating
    Timer(Duration(seconds: 2), () {
      navigate(isAuthenticated: isSignedIn);
    });
  }

  navigate({required bool isAuthenticated}) {
    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PropertyListing()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to RentEase',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Manage your properties with ease',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Icon(Icons.business, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Icon(Icons.location_city, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Icon(Icons.apartment_outlined, size: 30, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
