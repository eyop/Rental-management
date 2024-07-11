import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rental_management/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // check authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      // get user data from firestore
      await getUserDataFromFireStore();

      // save user data to shared preferences
      await saveUserDataToSharedPreferences();

      notifyListeners();

      isSignedIn = true;
    } else {
      isSignedIn = false;
    }

    return isSignedIn;
  }

  // login with email and password
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _uid = _auth.currentUser!.uid;
      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isSuccessful = false;
      notifyListeners();
      throw e;
    }
  }

  // signup with email and password
  Future<void> signup(String username, String email, String password,
      String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _uid = _auth.currentUser!.uid;
      _isLoading = false;
      _isSuccessful = true;

      // Create user document in Firestore
      UserModel newUser = UserModel(
        uid: _uid!,
        username: username,
        email: email,
        contact: phoneNumber,
        // Add additional fields as needed
      );

      await _firestore.collection('users').doc(_uid).set(
          newUser.toMap()); // Assuming toMap method is defined in UserModel

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isSuccessful = false;
      notifyListeners();
      throw e;
    }
  }

  // Method to send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e;
    }
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        'userModel', jsonEncode(_userModel!.toMap()));
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString('userModel') ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }
}
