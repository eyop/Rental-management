import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/models/user_model.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import '../utils/method_utils.dart'; // Import your utility methods here

class PropertyDetails extends StatefulWidget {
  static const routeName = "/property-details"; // Route name for navigation
  final PropertyModel rentModel; // Property model passed to this widget

  const PropertyDetails({
    Key? key,
    required this.rentModel,
  }) : super(key: key);

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  int currentView = 1; // Track current image view index
  var dateFormat =
      DateFormat("dd, MM, yyyy"); // Date format for displaying dates
  String requestStatus = "Request Rent"; // Initial request button text
  Color requestButtonColor = Colors.blueAccent; // Initial request button color
  bool showCancelButton = false; // Whether to show cancel button
  bool canRequestRent = false; // Whether the user can request rent

  @override
  void initState() {
    super.initState();
    _checkRequestStatus(); // Check initial request status
    _checkIfUserCanRequestRent(); // Check if the user can request rent
  }

  // Check if the current user can request rent for this property
  Future<void> _checkIfUserCanRequestRent() async {
    final userModel = context.read<AuthenticationProvider>().userModel;
    if (userModel != null && userModel.uid != widget.rentModel.userId) {
      setState(() {
        canRequestRent = true;
      });
    }
  }

  // Check if user has already requested this property
  Future<void> _checkRequestStatus() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('rental_requests')
        .where('ownerId', isEqualTo: widget.rentModel.id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming you want to check the status of the first matching document
      var request = querySnapshot.docs.first;
      String status = request.data()['status'] ?? 'requested';
      _updateRequestStatus(status);
    }
  }

  // Update UI based on the request status
  void _updateRequestStatus(String status) {
    setState(() {
      switch (status) {
        case 'requested':
          requestStatus = "Request Sent - Pending Approval";
          requestButtonColor = Colors.orange;
          showCancelButton = true;
          break;
        case 'accepted':
          requestStatus = "Request Approved";
          requestButtonColor = Colors.green;
          showCancelButton = false;
          break;
        case 'declined':
          requestStatus = "Request Declined";
          requestButtonColor = Colors.red;
          showCancelButton = false;
          break;
        default:
          requestStatus = "Request Rent";
          requestButtonColor = Colors.blueAccent;
          showCancelButton = false;
      }
    });
  }

  // Handle user's request to rent the property
  Future<void> _handleRequest() async {
    final userModel = context.read<AuthenticationProvider>().userModel;
    var request = await FirebaseFirestore.instance
        .collection('rental_requests')
        .doc(widget.rentModel.id)
        .get();

    if (!request.exists) {
      // If request doesn't exist, create a new request document
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(widget.rentModel.id)
          .set({
        'userId': widget.rentModel.userId, // ID of the user making the request
        'name': userModel?.username, // ID of the user making the request
        'ownerId': userModel?.uid, // ID of the user receiving the request
        'propertyId': widget.rentModel.id, // ID of the property being requested
        'status': 'requested', // Initial status of the request
        'timestamp': FieldValue
            .serverTimestamp(), // Timestamp of when the request was made
      });

      _updateRequestStatus('requested'); // Update UI with new request status
    }
  }

  // Cancel user's existing request to rent the property
  Future<void> _cancelRequest() async {
    await FirebaseFirestore.instance
        .collection('rental_requests')
        .doc(widget.rentModel.id)
        .delete();

    setState(() {
      // Reset UI to initial state after canceling the request
      requestStatus = "Request Rent";
      requestButtonColor = Colors.blueAccent;
      showCancelButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postedDate = getDateFromDateTimeInSpecificFormat(
        dateFormat, widget.rentModel.updatedAt ?? "dd MM, yyyy");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(), // Build the app bar with property details
          _buildSliverListBody(
              postedDate), // Build the body with property details
        ],
      ),
    );
  }

  // Build widget for displaying property images
  Widget _buildImageWidget(String imageUrl) {
    return SizedBox(
      child: imageUrl.isEmpty
          ? placeHolderAssetWidget() // Placeholder if no image available
          : fetchImageWithPlaceHolder(
              imageUrl), // Utility method to fetch image
    );
  }

  // Build list of property details
  List<Widget> _buildPropertyDetails() {
    var model = widget.rentModel;

    return model.details!.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key, // Property detail key (e.g., "Bedrooms")
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "${entry.value}", // Property detail value (e.g., "3")
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Build the app bar for property details
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      titleSpacing: 0.0,
      expandedHeight: MediaQuery.of(context).size.height * 0.35,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "ETB. ${widget.rentModel.price}", // Display property price in app bar
          style: const TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
        background: Hero(
          tag: widget.rentModel.id ?? "selected",
          child: widget.rentModel.images != null &&
                  widget.rentModel.images!.isNotEmpty
              ? Stack(
                  children: <Widget>[
                    PageView.builder(
                      onPageChanged: (view) {
                        setState(() {
                          currentView = view + 1;
                        });
                      },
                      itemCount: widget.rentModel.images!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildImageWidget(
                            widget.rentModel.images![index]);
                      },
                    ),
                    Positioned(
                      bottom: 20.0,
                      right: 20.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "$currentView",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                            const Text(
                              " / ",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                            Text(
                              "${widget.rentModel.images!.length}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(color: Colors.grey), // Placeholder if no images
        ),
      ),
    );
  }

  // Build the body with property details and request buttons
  Widget _buildSliverListBody(String postedDate) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (canRequestRent)
          GestureDetector(
            onTap: () async {
              if (requestStatus == "Request Rent") {
                await _handleRequest(); // Handle tap on request button
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [requestButtonColor, Colors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              width: double.infinity,
              height: 50.0,
              child: Center(
                child: Text(
                  requestStatus,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        if (canRequestRent && showCancelButton)
          GestureDetector(
            onTap: () async {
              await _cancelRequest(); // Handle tap on cancel request button
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              width: double.infinity,
              height: 50.0,
              child: const Center(
                child: Text(
                  "Cancel Request",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              "Posted on $postedDate", // Display property posted date
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
          ),
        ),
        ..._buildPropertyDetails(), // Display property details
        _propertyAddressView("Region",
            widget.rentModel.region!), // Display property address details
        _propertyAddressView("City", widget.rentModel.city!),
        _propertyAddressView("Subcity", widget.rentModel.subcity!),
        _propertyAddressView("Contact", widget.rentModel.contact!),
        _propertyAddressView("Description", widget.rentModel.description ?? ''),
      ]),
    );
  }

  // Build widget for displaying property address details
  Widget _propertyAddressView(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.5),
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.0, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
