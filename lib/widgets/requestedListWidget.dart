import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/models/rent_model.dart';
import 'package:rental_management/screens/property_details.dart';

class RequestedListWidget extends StatefulWidget {
  final List<RentModel> requestedProps1;

  RequestedListWidget({Key? key, required this.requestedProps1})
      : super(key: key);

  @override
  _RequestedListWidgetState createState() => _RequestedListWidgetState();
}

class _RequestedListWidgetState extends State<RequestedListWidget> {
  List<PropertyModel> requestedProps = [];

  @override
  void initState() {
    super.initState();
    _fetchRequestedProperties();
  }

  Future<void> _fetchRequestedProperties() async {
    try {
      List<PropertyModel> properties = [];

      // Fetch properties based on propertyIds in requestedProps1
      for (var request in widget.requestedProps1) {
        DocumentSnapshot propertySnapshot = await FirebaseFirestore.instance
            .collection('properties')
            .doc(request.propertyId)
            .get();

        PropertyModel property = PropertyModel.fromFirestore(
          propertySnapshot.data() as Map<String, dynamic>,
        );
        properties.add(property);
      }

      setState(() {
        requestedProps = properties;
      });
    } catch (e) {
      print('Error fetching requested properties: $e');
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

      // If accepting, update property availability to false
      if (newStatus == 'accepted') {
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(rentModel.ounerId)
            .update({'availability': false});
      }

      // Refresh UI after update
      _fetchRequestedProperties();
    } catch (e) {
      print('Error updating request status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return requestedProps.isEmpty
        ? Center(
            child: Text(
              "No data found!!",
              style: TextStyle(fontSize: 20),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            itemCount: requestedProps.length,
            itemBuilder: (BuildContext context, int index) {
              var property = requestedProps[index];
              var rentModel = widget.requestedProps1[index];
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
                  margin:
                      const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: Image.asset(
                            "assets/images/bg_placeholder.jpg", // Replace with your image logic
                            fit: BoxFit.cover,
                          ),
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
                                "Property: ${property.propertyType}",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Requester: ${rentModel.name}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Price: ${property.price}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.openSans().fontFamily,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Description: ${property.description}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.openSans().fontFamily,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "City: ${property.city}",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily:
                                          GoogleFonts.openSans().fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                              if (rentModel.status == 'requested')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.greenAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        _updateRequestStatus(
                                            rentModel, 'accepted');
                                      },
                                      child: Text(
                                        "Approve",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        _updateRequestStatus(
                                            rentModel, 'declined');
                                      },
                                      child: Text(
                                        "Decline",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              if (rentModel.status == 'accepted')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        _updateRequestStatus(
                                            rentModel, 'terminated');
                                      },
                                      child: Text(
                                        "Terminate",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              if (rentModel.status == 'declined')
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "This request has been declined.",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              if (rentModel.status == 'terminated')
                                Padding(
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
            separatorBuilder: (context, index) => SizedBox(height: 20),
          );
  }
}
