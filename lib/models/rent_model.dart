import 'package:cloud_firestore/cloud_firestore.dart';

class RentModel {
  String ounerId;
  final String propertyId;
  final String userId;
  final String status;
  final String createdAt;
  final String name;

  RentModel({
    required this.ounerId,
    required this.propertyId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.name,
  });

  factory RentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RentModel(
      ounerId: doc.id,
      propertyId: data['propertyId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'] ?? '',
      name: data['name'] ?? '',
    );
  }
}