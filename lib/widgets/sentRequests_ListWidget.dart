import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/models/rent_model.dart';
import 'package:rental_management/screens/property_details.dart';
import 'package:rental_management/screens/property_listing.dart';
import 'package:rental_management/utils/method_utils.dart';
import 'package:async/async.dart';

class SentRequestsListWidget extends StatefulWidget {
  final List<RentModel> sentRequests1;

  const SentRequestsListWidget({super.key, required this.sentRequests1});

  @override
  _SentRequestsListWidgetState createState() => _SentRequestsListWidgetState();
}

class _SentRequestsListWidgetState extends State<SentRequestsListWidget> {
  List<PropertyModel> sentRequests = [];
  bool isFetching = true;
  CancelableOperation<void>? _fetchOperation;
  @override
  void initState() {
    super.initState();
    _fetchSentRequests();
  }

  @override
  void dispose() {
    _fetchOperation?.cancel(); // Cancel any ongoing fetch operation
    super.dispose();
  }

  Future<void> _fetchSentRequests() async {
    _fetchOperation = CancelableOperation.fromFuture(_fetchProperties());

    setState(() {
      isFetching = true;
    });

    try {
      await _fetchOperation!.value;

      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    } catch (e) {
      print('Error fetching sent requests: $e');
      if (mounted) {
        setState(() {
          isFetching = false;
        });
      }
    }
  }

  Future<void> _fetchProperties() async {
    List<PropertyModel> properties = [];

    // Fetch properties based on propertyIds in sentRequests1
    for (var request in widget.sentRequests1) {
      DocumentSnapshot propertySnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .doc(request.propertyId)
          .get();

      if (propertySnapshot.exists) {
        PropertyModel property = PropertyModel.fromFirestore(
          propertySnapshot.data() as Map<String, dynamic>,
        );
        properties.add(property);
      }
    }

    if (mounted) {
      setState(() {
        sentRequests = properties;
      });
    }
  }

  Future<void> _updateRequestStatus(
      RentModel rentModel, String newStatus) async {
    try {
      // Update status in rental_requests collection
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(rentModel.propertyId)
          .update({'status': newStatus});

      // If terminating, update property availability to true
      if (newStatus == 'terminated') {
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(rentModel.propertyId)
            .update({'availability': true});
      }

      // Refresh UI after update
      _fetchSentRequests();
    } catch (e) {
      print('Error updating request status: $e');
    }
  }

  Future<void> _removeRequest(RentModel rentModel) async {
    try {
      await FirebaseFirestore.instance
          .collection('rental_requests')
          .doc(rentModel.propertyId)
          .delete();

      // Refresh UI after deletion
      _fetchSentRequests();
      _showSuccessAnimation();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => PropertyListing()),
      // );
    } catch (e) {
      print('Error removing request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sentRequests.isEmpty) {
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              height: 300,
              child: Image.asset(
                'assets/images/Empty-pana.png',
                fit: BoxFit.cover, // Adjust this as needed
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No data found!!",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSentRequests,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        itemCount: sentRequests.length,
        itemBuilder: (BuildContext context, int index) {
          var property = sentRequests[index];
          var rentModel = widget.sentRequests1[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetails(
                    rentModel: property,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              elevation: 5,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14.0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14.0),
                      bottomLeft: Radius.circular(14.0),
                    ),
                    child: SizedBox(
                      height: 240,
                      width: 120,
                      child: property.images == null ||
                              property.images!.isEmpty ||
                              property.images![0].isEmpty
                          ? placeholderAssetWidget()
                          : fetchImageWithPlaceHolder(property.images![0]),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ETB ${property.price}",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Requester: ${rentModel.name}",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Price: ${property.price}",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "City: ${property.city}",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Description: ${property.description}",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                ),
                              ),
                            ],
                          ),
                          if (rentModel.status == 'requested') ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Waiting for approval",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _removeRequest(rentModel);
                                  },
                                  child: const Text(
                                    "Cancel Request",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (rentModel.status == 'accepted') ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                "You are approved",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _updateRequestStatus(
                                        rentModel, 'terminated');
                                  },
                                  child: const Text(
                                    "Terminate",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (rentModel.status == 'declined')
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Your request is declined",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          if (rentModel.status == 'terminated')
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Terminated",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 20),
      ),
    );
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
                      'Action completed successfully!',
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
}

// Utility method to fetch image
Widget fetchImageWithPlaceHolder(String imageUrl) => imageUrl.isNotEmpty
    ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
      )
    : placeholderAssetWidget();

// Placeholder widget for images
Widget placeholderAssetWidget() => const Icon(
      Icons.house_outlined,
      size: 120.0,
      color: Colors.black26,
    );
