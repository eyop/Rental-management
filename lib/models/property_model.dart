import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

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
  final GeoPoint propertyLocation;

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
    GeoPoint? propertyLocation,
  }) : propertyLocation = propertyLocation ??
            GeoPoint(latitude: 9.03, longitude: 38.74); // Addis Ababa default

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
      propertyLocation: data['propertyLocation'] != null
          ? GeoPoint(
              latitude: data['propertyLocation']['latitude'],
              longitude: data['propertyLocation']['longitude'],
            )
          : GeoPoint(latitude: 9.03, longitude: 38.74), // Addis Ababa default
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
      'propertyLocation': {
        'latitude': propertyLocation.latitude,
        'longitude': propertyLocation.longitude,
      },
    };
  }
}
