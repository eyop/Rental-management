import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_management/models/dummy_data.dart';
import 'package:rental_management/utils/method_utils.dart';
import '../models/property_model.dart'; // Import property model
import 'property_details.dart'; // Import property details screen
import 'property_post.dart'; // Import property post screen

class PropertyListing extends StatefulWidget {
  const PropertyListing({Key? key}) : super(key: key);

  @override
  State<PropertyListing> createState() => _PropertyListingState();
}

class _PropertyListingState extends State<PropertyListing> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey(); // Scaffold key for showing snackbar
  bool isFetching = false; // Flag to indicate if data is being fetched
  List<PropertyModel> propertyRentList = [];
  List<PropertyModel> requestedProps = [];
  @override
  void initState() {
    super.initState();
    _fetchPropertyList(); // Fetch initial property list on widget initialization
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: const Text("Property Listing"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: Colors.black, // Dark background for tabs
              child: TabBar(
                labelColor: Colors.redAccent, // Selected tab label color
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white, // Indicator color
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.list),
                    text: "Properties",
                  ),
                  Tab(
                    icon: Icon(Icons.request_page),
                    text: "Requests",
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            isFetching
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator while fetching data
                : _buildPropertyList(), // Show property list when not fetching
            _buildRequestedList(), // Show requested list
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () {
            try {
              // Navigate to property post screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PropertyPost()),
              );
            } catch (e) {
              // Show error snackbar if navigation fails
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildImage(PropertyModel rentModel) {
    // return Hero(
    //   tag: rentModel.id ??
    //       "tag_${rentModel.hashCode}", // Hero animation tag for property image
    //   child: SizedBox(
    //     height: 120,
    //     width: 120,
    //     child: (rentModel.images == null ||
    //             rentModel.images!.isEmpty ||
    //             rentModel.images![0].isEmpty)
    //         ? placeHolderAssetWidget() // Placeholder widget for empty image
    //         : fetchImageWithPlaceHolder(
    //             rentModel.images![0]), // Fetch property image with placeholder
    //   ),
    // );
    return SizedBox(
      height: 120,
      width: 120,
      child: (rentModel.images == null ||
              rentModel.images!.isEmpty ||
              rentModel.images![0].isEmpty)
          ? placeHolderAssetWidget() // Placeholder widget for empty image
          : fetchImageWithPlaceHolder(
              rentModel.images![0]), // Fetch property image with placeholder
    );
  }

  Widget _buildPropertyInfo(PropertyModel rentModel) {
    var rrow = Row(
      children: [
        Text(rentModel.description ?? ''),
      ],
      // rentModel.details!.entries
      //     .take(2)
      //     .map((entry) =>
      //         Text("${entry.key}: ${entry.value}")) // Display property details
      //     .toList(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
          child: Text(
            "ETB ${rentModel.price}", // Display property price
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: double.infinity, child: rrow),
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
          child: Row(
            children: [
              Icon(Icons.phone, color: Theme.of(context).primaryColor),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(rentModel.contact ??
                    ""), // Display property contact information
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyList() {
    if (propertyRentList.isEmpty) {
      return const Center(
        child: Text(
          "No data found!!", // Display message when no properties are available
          style: TextStyle(fontSize: 20),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      itemCount: propertyRentList.length,
      itemBuilder: (BuildContext context, int index) {
        var rentModel = propertyRentList[index];
        return GestureDetector(
          onTap: () {
            // Navigate to property details screen on tap
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetails(
                  rentModel: rentModel,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            elevation: 5,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                    child: _buildImage(rentModel), // Build property image
                  ),
                  Expanded(
                    child: _buildPropertyInfo(
                        rentModel), // Build property information
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 20),
    );
  }

  Widget _buildRequestedList() {
    if (requestedProps.isEmpty) {
      return const Center(
        child: Text(
          "No data found!!", // Display message when no requested properties are available
          style: TextStyle(fontSize: 20),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      itemCount: requestedProps.length,
      itemBuilder: (BuildContext context, int index) {
        var rentModel = requestedProps[index];
        return GestureDetector(
          onTap: () {
            // Navigate to property details screen on tap
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetails(
                  rentModel: rentModel,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            elevation: 5,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                    ),
                    child: _buildImage(rentModel), // Build property image
                  ),
                  Expanded(
                    child: _buildRequestedPropertyInfo(
                        rentModel), // Build requested property information
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 20),
    );
  }

  Widget _buildRequestedPropertyInfo(PropertyModel rentModel) {
    var rrow = Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Row(
        children: rentModel.details!.entries
            .take(2)
            .map((entry) => Text(
                "${entry.key}: ${entry.value}")) // Display property details
            .toList(),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
          child: Text(
            "ETB ${rentModel.price}", // Display property price
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: double.infinity, child: rrow),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Approve",
                  style: TextStyle(color: Colors.black), // Button text color
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Decline",
                  style: TextStyle(color: Colors.black), // Button text color
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _fetchPropertyList() async {
    try {
      // Assuming 'properties' is your Firestore collection reference
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('properties').get();
      print("////////////////////////////////////////////");
      print(querySnapshot.docs);
      setState(() {
        propertyRentList = querySnapshot.docs
            .map((doc) =>
                PropertyModel.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }
}
