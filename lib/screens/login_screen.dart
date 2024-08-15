import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'landing_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _resetPassword(BuildContext context, String email) async {
    try {
      await Provider.of<AuthenticationProvider>(context, listen: false)
          .resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent. Check your inbox.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_open,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Login',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(12.0), // Decreased radius
                  ),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(12.0), // Decreased radius
                  ),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text;

                  try {
                    await Provider.of<AuthenticationProvider>(context,
                            listen: false)
                        .login(email, password);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LandingScreen()),
                    );
                  } on FirebaseAuthException catch (e) {
                    String errorMessage = 'Login failed.';

                    if (e.code == 'user-not-found') {
                      errorMessage = 'No user found with this email.';
                    } else if (e.code == 'wrong-password') {
                      errorMessage = 'Incorrect password.';
                    } else {
                      errorMessage = 'Error: ${e.message}';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  } catch (e) {
                    print('Unexpected error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('An unexpected error occurred.'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  foregroundColor: theme.colorScheme.primary, // Use theme color
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  _resetPassword(context, _emailController.text.trim());
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary, // Use theme color
                ),
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary, // Use theme color
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
