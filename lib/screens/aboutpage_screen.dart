import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Property Rental Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Our Property Rental Management app aims to simplify the process of renting properties. '
                'Users can easily list their properties, manage rental requests, and find their perfect rental '
                'property. Our mission is to make property rental seamless and efficient for both landlords and tenants.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Features:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('- Easy property listing and management',
                  style: TextStyle(fontSize: 16)),
              Text('- Simple rental request handling',
                  style: TextStyle(fontSize: 16)),
              Text('- Detailed property information',
                  style: TextStyle(fontSize: 16)),
              Text('- User-friendly interface', style: TextStyle(fontSize: 16)),
              Text('- Secure and reliable', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
