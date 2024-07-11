import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/firebase_options.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'package:rental_management/screens/landing_screen.dart';
import 'package:rental_management/screens/login_screen.dart';
import 'package:rental_management/screens/property_listing.dart';
import 'package:rental_management/screens/property_post.dart';
import 'package:rental_management/screens/signup_screen.dart';
import 'package:rental_management/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthenticationProvider(),
      child: MaterialApp(
        theme: CustomTheme.themeData,
        initialRoute: '/',
        routes: {
          '/': (context) => LandingScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/property_listing': (context) => const PropertyListing(),
          '/propertyposting': (context) => const PropertyPost(),
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: LandingScreen(),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
