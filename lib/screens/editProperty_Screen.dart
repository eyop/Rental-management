import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'package:rental_management/utils/method_utils.dart';

class EditPropertyScreen extends StatefulWidget {
  final PropertyModel propertyModel;

  const EditPropertyScreen({Key? key, required this.propertyModel})
      : super(key: key);

  @override
  _EditPropertyScreenState createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _subcityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  List<String> _imageUrls = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _priceController.text = widget.propertyModel.price.toString();
    _regionController.text = widget.propertyModel.region;
    _cityController.text = widget.propertyModel.city;
    _subcityController.text = widget.propertyModel.subcity;
    _descriptionController.text = widget.propertyModel.description;
    _contactController.text = widget.propertyModel.contact;
    _imageUrls = widget.propertyModel.images ?? [];
  }

  Future<void> _updateProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userModel = context.read<AuthenticationProvider>().userModel;
    if (userModel == null) {
      return; // Handle the case where the user is not authenticated
    }

    try {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.propertyModel.id)
          .update({
        'price': _priceController.text,
        'region': _regionController.text,
        'city': _cityController.text,
        'subcity': _subcityController.text,
        'description': _descriptionController.text,
        'contact': _contactController.text,
        'images': _imageUrls,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully')),
      );

      // Navigate to PropertyListingScreen after update
      // Navigator.of(context).popUntil(ModalRoute.withName('/property-listing'));
      Navigator.of(context).pushReplacementNamed('/property_listing');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update property: $error')),
      );
    }
  }

  Future<void> _deleteProperty() async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this property?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      try {
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(widget.propertyModel.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property deleted successfully')),
        );

        // Navigate to PropertyListingScreen after delete
        Navigator.of(context).pushReplacementNamed('/property_listing');
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete property: $error')),
        );
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String imageUrl =
          await context.read<AuthenticationProvider>().uploadImage(file);
      setState(() {
        _imageUrls.add(imageUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Add/Edit Images Section
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _getImage(ImageSource.gallery),
                child: Text('Add Image', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              _imageUrls.isNotEmpty
                  ? SizedBox(
                      height: 100.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: <Widget>[
                              Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                margin: const EdgeInsets.all(5.0),
                                child: Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 5,
                                top: 5,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _imageUrls.removeAt(index);
                                      // Implement deletion from Firebase Storage if necessary
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Container(),

              // Property Details Section
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(labelText: 'Region'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the region';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _subcityController,
                decoration: const InputDecoration(labelText: 'Subcity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the subcity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _updateProperty,
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _deleteProperty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
