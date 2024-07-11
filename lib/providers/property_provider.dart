import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_management/models/property_model.dart';

class PropertyProvider extends ChangeNotifier {
  List<PropertyModel> propertyRentList = [];

  Future<void> fetchProperties() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('properties').get();
      propertyRentList = querySnapshot.docs
          .map((doc) =>
              PropertyModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }
}
