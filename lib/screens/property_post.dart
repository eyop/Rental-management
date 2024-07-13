import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import '../models/property_model.dart';

class PropertyPost extends StatefulWidget {
  static const String routeName = '/property-post';

  const PropertyPost({Key? key}) : super(key: key);

  @override
  State<PropertyPost> createState() => _PropertyPostState();
}

class _PropertyPostState extends State<PropertyPost> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  List<Map<String, dynamic>> propertyTypes = [
    {"name": "Apartment", "icon": Icons.apartment},
    {"name": "Flat", "icon": Icons.home},
    {"name": "Plot/Land", "icon": Icons.landscape},
    {"name": "Vehicle", "icon": Icons.directions_car},
    {"name": "Other", "icon": Icons.category}, // Example for other types
  ];

  String _subcity = "";
  String _city = "";
  String _region = "";
  String _description = "";
  String _contact = "";
  double _price = 0.0;

  int selected = 0;
  final List<String> _imageFilesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text("Rent Property"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildLabel("PROPERTY TYPE"),
                      _buildPropertyTypesWidget(),
                      _buildLabel("PROPERTY PHOTOS"),
                      _buildPropertyPhotosWidget(),
                      _buildLabel("PROPERTY ADDRESS"),
                      _buildPropertyLocationWidget(),
                      _buildLabel("PRICE"),
                      _buildPriceWidget(),
                      _buildLabel("CONTACT DETAILS"),
                      _buildContactDetailsWidget(),
                      _buildLabel("OTHER DETAILS"),
                      _buildDescription(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildSubmitPostWidget(),
        ],
      ),
    );
  }

  Widget _buildContactDetailsWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Contact field is required!!";
            }
            return null;
          },
          onSaved: (String? value) {
            _contact = value!;
          },
          keyboardType: TextInputType.number,
          maxLength: 10,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            counterText: "",
            labelText: "Contact",
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Description is required!";
            }
            return null;
          },
          onChanged: (value) {
            _description = value;
          },
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: "Additional Property Description",
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildPriceWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          validator: (String? price) {
            if (price == null || price.isEmpty) {
              return "Price field is required!!";
            }
            return null;
          },
          onSaved: (value) {
            _price = double.tryParse(value!)!;
          },
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: "Price",
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyLocationWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Region (Optional)",
                labelStyle: TextStyle(color: Colors.grey),
              ),
              onSaved: (value) {
                _region = value!;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "City",
                labelStyle: TextStyle(color: Colors.grey),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "City field is required!";
                }
                return null;
              },
              onSaved: (value) {
                _city = value!;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: TextFormField(
              validator: (String? value) {
                if (value?.isEmpty ?? false) {
                  return "Sub-city field is required!!";
                }
                return null;
              },
              onSaved: (value) {
                _subcity = value!;
              },
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: "Sub City",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPhotosWidget() {
    return Container(
      color: Colors.white,
      height: 120.0,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFilesList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.grey,
                  size: 50.0,
                ),
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: FileImage(File(_imageFilesList[index - 1])),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    _removeImage(index - 1);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageFilesList.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFilesList.add(pickedFile.path);
      });
    }
  }

  Widget _buildPropertyTypesWidget() {
    return Container(
      color: Colors.white,
      height: 80.0,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: propertyTypes.length,
        itemBuilder: (BuildContext context, int index) {
          final isSelected = selected == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selected = index;
              });
            },
            child: Container(
              width: 120.0,
              margin: const EdgeInsets.only(left: 20.0, right: 10.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    propertyTypes[index]['icon'],
                    size: 30.0,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    propertyTypes[index]['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitPostWidget() {
    final uid = context.read<AuthenticationProvider>().uid;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          _submitPost(uid);
        },
        child: const Text(
          "Post Property",
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  void _submitPost(String? uid) async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing while uploading
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(), // Or your custom loading widget
          );
        },
      );

      try {
        // Upload images to Firebase Storage and get download URLs
        List<String> imageUrls = await _uploadImages();

        // Create a PropertyModel instance with all details including image URLs
        PropertyModel property = PropertyModel(
          userId: uid!,
          propertyType: propertyTypes[selected + 1]['name'],
          images: imageUrls,
          region: _region,
          city: _city,
          subcity: _subcity,
          price: _price.toString(),
          contact: _contact,
          description: _description,
          availability: true,
          updatedAt: DateTime.now().toIso8601String(),
          id: '',
        );
        // print("///////////////////////////////////");
        // print("Property Type: ${propertyTypes[selected + 1]['name']}");
        // print("Property Photos: $_imageFilesList");
        // print("Region: $_region, City: $_city, Sub-city: $_subcity");
        // print("Price: $_price");
        // print("Contact: $_contact");
        // print("Description: $_description");
        // print("///////////////////////////////////");

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('properties')
            .add(property.toMap());

// Set the auto-generated document ID to your PropertyModel instance
        String propertyId = docRef.id;
        property.id = propertyId;

// Now you can store the updated PropertyModel instance with the document ID
        await docRef.set(property.toMap());
        // Hide loading indicator
        Navigator.of(context).pop();
        _showSuccessAnimation();

        // Clear the form and image list
        _clearForm();
      } catch (e) {
        // Hide loading indicator
        Navigator.of(context).pop();
        // Show error message
        _showErrorAnimation();
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    // Upload each image to Firebase Storage
    for (String imagePath in _imageFilesList) {
      File imageFile = File(imagePath);
      String imageName = Path.basename(imageFile.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$imageName');

      try {
        // Upload image
        await storageReference.putFile(imageFile);

        // Get download URL
        String downloadURL = await storageReference.getDownloadURL();
        imageUrls.add(downloadURL);
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }

    return imageUrls;
  }

  void _clearForm() {
    setState(() {
      _subcity = "";
      _city = "";
      _region = "";
      _description = "";
      _contact = "";
      _price = 0.0;
      selected = 0;
      _imageFilesList.clear();
    });
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeInBack,
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60.0,
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Property posted successfully!',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pushReplacementNamed(
                            '/property_listing'); // Navigate to home screen
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorAnimation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to post property. Please try again.  '),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
