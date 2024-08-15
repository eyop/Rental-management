import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'package:rental_management/screens/property_listing.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkAuthState(context),
        builder: (context, snapshot) {
          print("snapshot.hasData: " + snapshot.connectionState.toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          } else if (snapshot.hasData && snapshot.data == true) {
            // Navigate to PropertyListing if authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const PropertyListing()),
              );
            });
          } else {
            // Navigate to LoginScreen if not authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            });
          } // Default return
          return _buildLoadingScreen();
        },
      ),
    );
  }

  Future<bool> _checkAuthState(BuildContext context) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return await authProvider.checkAuthenticationState();
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.apartment, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Welcome to URP',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Manage your properties with ease',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          const CircularProgressIndicator(), // Loading indicator
          const SizedBox(height: 20),
          const Row(
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
    );
  }
}
