import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'landing_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _phoneNumber = '';

  bool _passwordsMatch = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.key),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                ),
                obscureText: true,
                onChanged: (_) {
                  setState(() {
                    _passwordsMatch = _passwordController.text ==
                        _confirmPasswordController.text;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.key),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                  errorText: !_passwordsMatch ? 'Passwords do not match' : null,
                ),
                obscureText: true,
                onChanged: (_) {
                  setState(() {
                    _passwordsMatch = _passwordController.text ==
                        _confirmPasswordController.text;
                  });
                },
              ),
              const SizedBox(height: 10),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius:
                        BorderRadius.circular(12.0), // Decreased radius
                  ),
                ),
                initialCountryCode: 'US',
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _passwordsMatch
                    ? () async {
                        try {
                          await Provider.of<AuthenticationProvider>(context,
                                  listen: false)
                              .signup(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                            _phoneNumber,
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LandingScreen()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Sign up failed: $e'),
                            backgroundColor: theme.colorScheme.error,
                          ));
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // Use theme color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
