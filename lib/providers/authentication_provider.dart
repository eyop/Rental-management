import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/models/rent_model.dart';
import 'package:rental_management/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

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
    print("Entering: checkAuthenticationState");
    bool isSignedIn = false;
    print("Checking current user on Firebase Auth...");
    if (_auth.currentUser != null) {
      print("User found, fetching user ID...");
      _uid = _auth.currentUser!.uid;
      // get user data from firestore
      await getUserDataFromFireStore();

      // save user data to shared preferences
      await saveUserDataToSharedPreferences();

      notifyListeners();

      isSignedIn = true;
    } else {
      print("No user found on Firebase Auth.");
      isSignedIn = false;
    }

    print("Exiting: checkAuthenticationState");
    return isSignedIn;
  }

  // login with email and password
  Future<void> login(String email, String password) async {
    print("Entering: login");
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
      print("Login successful, user ID: $_uid");
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isSuccessful = false;
      print("Login failed: $e");
      notifyListeners();
      throw e;
    }

    print("Exiting: login");
  }

  // signup with email and password
  Future<void> signup(String username, String email, String password,
      String phoneNumber) async {
    print("Entering: signup");
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

    print("Exiting: signup");
  }

  // Method to send password reset email
  Future<void> resetPassword(String email) async {
    print("Entering: resetPassword");
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to: $email");
    } catch (e) {
      throw e;
    }

    print("Exiting: resetPassword");
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    print("Entering: getUserDataFromFireStore");
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();

    print("Exiting: getUserDataFromFireStore");
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    print("Entering: saveUserDataToSharedPreferences");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        'userModel', jsonEncode(_userModel!.toMap()));

    print("Exiting: saveUserDataToSharedPreferences");
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    print("Entering: getUserDataFromSharedPreferences");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString('userModel') ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();

    print("Exiting: getUserDataFromSharedPreferences");
  }

  // logout
  Future<void> logout() async {
    print("Entering: logout");
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
    //Navigator.of(context).pushReplacementNamed('/');

    print("Exiting: logout");
  }

  // Fetch properties from Firestore
  Future<List<PropertyModel>> fetchProperties() async {
    print("Entering: fetchProperties");
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .where('availability', isEqualTo: true)
          .get();
      List<PropertyModel> properties = querySnapshot.docs
          .map((doc) =>
              PropertyModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
      print("Exiting: fetchProperties");
      return properties;
    } catch (e) {
      print('Error fetching properties: $e');
      throw e;
    }
  }

  // Fetch requested properties
  Future<List<RentModel>> fetchRequestProps() async {
    print("Entering: fetchRequestProps");
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rental_requests')
          .where(
            'ownerId',
            isEqualTo: _uid,
          ) // Assuming _uid is set during authentication
          .get();
      List<RentModel> requestedProps = querySnapshot.docs
          .map((doc) => RentModel.fromFirestore(doc))
          .toList();

      // print(requestedProps.length);
      return requestedProps;
    } catch (e) {
      print('Error fetching requested properties: $e');
      throw e;
    }
  }

  // Fetch sent requests where current user is the requester
  Future<List<RentModel>> fetchSentRequests() async {
    print("Entering: fetchSentRequests");
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rental_requests')
          .where('userId',
              isEqualTo: _uid) // Assuming _uid is set during authentication
          .get();
      List<RentModel> sentRequests = querySnapshot.docs
          .map((doc) => RentModel.fromFirestore(doc))
          .toList();
      print("Exiting: fetchSentRequests");
      return sentRequests;
    } catch (e) {
      print('Error fetching sent requests: $e');
      throw e;
    }
  }

  // Check if the current user can request rent for a property
  Future<bool> canRequestRent(String propertyId) async {
    print("Entering: canRequestRent");
    try {
      final userModel = _userModel;
      if (userModel != null) {
        var querySnapshot = await FirebaseFirestore.instance
            .collection('rental_requests')
            .where('ownerId', isEqualTo: propertyId)
            .get();

        print("Exiting: canRequestRent");
        return querySnapshot.docs.isEmpty;
      }
      print("Exiting: canRequestRent (user not found)");
      return false;
    } catch (e) {
      print('Error checking if user can request rent: $e');
      throw e;
    }
  }

  // Handle user's request to rent the property
  Future<void> createRentalRequest(
      {String? userId,
      String? username,
      required String ownerId,
      required String propertyId,
      required String status}) async {
    try {
      print("Entering: createRentalRequest");
      final userModel = _userModel;
      var request = await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(propertyId)
          .get();

      if (!request.exists) {
        await FirebaseFirestore.instance
            .collection('rental_requests')
            .doc(propertyId)
            .set({
          'userId': _uid, // ID of the user making the request
          'name': userModel?.username, // Name of the user making the request
          'ownerId': ownerId, // ID of the user receiving the request
          'propertyId': propertyId, // ID of the property being requested
          'status': 'requested', // Initial status of the request
          'timestamp': FieldValue
              .serverTimestamp(), // Timestamp of when the request was made
        });
      }
    } catch (e) {
      print('Error handling request to rent property: $e');
      throw e;
    }
  }

  // Cancel user's existing request to rent the property
  Future<void> cancelRequestToRentProperty(String propertyId) async {
    print("Entering: cancelRequestToRentProperty");
    try {
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(propertyId)
          .delete();
    } catch (e) {
      print('Error canceling request to rent property: $e');
      throw e;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    print("Entering: canRequestRent");
    try {
      String imageName = path.basename(imageFile.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$imageName');

      // Upload image to Firebase Storage
      await storageReference.putFile(imageFile);

      // Get download URL
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Failed to upload image: $e');
      throw e; // Rethrow the exception to handle it in the UI
    }
  }
}
