import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PropertyModel {
  String id;
  final bool availability;
  List<String>? images;
  final String price;
  final String region;
  final String city;
  final String subcity;
  final String description;
  final String contact;
  final String updatedAt;
  final String userId;
  final String? propertyType;

  Map<String, dynamic>? details;

  PropertyModel({
    required this.id,
    required this.userId,
    required this.images,
    required this.availability,
    required this.region,
    required this.city,
    required this.subcity,
    required this.price,
    this.details,
    required this.description,
    required this.propertyType,
    required this.contact,
    required this.updatedAt,
  });

  factory PropertyModel.fromFirestore(Map<String, dynamic> data) {
    return PropertyModel(
      id: data['id'],
      availability: data['availability'] ?? false,
      images: List<String>.from(data['images'] ?? []),
      price: data['price'].toString(),
      region: data['region'] ?? '',
      city: data['city'] ?? '',
      subcity: data['subcity'] ?? '',
      description: data['description'] ?? '',
      contact: data['contact'] ?? '',
      updatedAt: data['updatedAt'] ?? '',
      userId: data['userId'] ?? '',
      propertyType: data['propertyType'] ?? '',
      details: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'availability': availability,
      'images': images,
      'price': price,
      'region': region,
      'city': city,
      'subcity': subcity,
      'description': description,
      'contact': contact,
      'updatedAt': updatedAt,
      'userId': userId,
      'propertyType': propertyType,
      'details': details,
    };
  }

  // factory PropertyModel.fromMap(Map<String, dynamic> value)
  // // factory PropertyModel.fromJson(Map<String, dynamic> value)
  // {
  //   var images = [];
  //   try {
  //     final List<dynamic>? data = value["image"];
  //     if (data != null) {
  //       images = List<String>.from(data);
  //     }
  //   } catch (error) {
  //     images = [];
  //   }

  //   return PropertyModel(
  //     id: value["id"],
  //     images: images as List<String>,
  //     price: value["price"],
  //     details: value['details'],
  //     region: value['region'],
  //     city: value['city'],
  //     subcity: value['subcity'],
  //     description: value["description"],
  //     propertyType: value["propertyType"],
  //     contact: value["contact"],
  //     updatedAt: value["updatedAt"],
  //   );
  // }
}
