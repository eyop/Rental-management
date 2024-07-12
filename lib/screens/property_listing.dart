import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/models/rent_model.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'package:rental_management/screens/property_details.dart';
import 'package:rental_management/screens/property_post.dart';
import 'package:rental_management/widgets/propertyListWidget.dart';
import 'package:rental_management/widgets/requestedListWidget.dart';
import 'package:rental_management/widgets/sentRequestsListWidget.dart';

class PropertyListing extends StatefulWidget {
  const PropertyListing({Key? key}) : super(key: key);

  @override
  State<PropertyListing> createState() => _PropertyListingState();
}

class _PropertyListingState extends State<PropertyListing> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool isFetching = false;
  String? uid;

  List<PropertyModel> propertyRentList = [];
  List<RentModel> requestedProps = [];
  List<RentModel> sentRequests = [];

  @override
  void initState() {
    super.initState();
    uid = context.read<AuthenticationProvider>().uid;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isFetching = true;
      });
      await Future.wait([
        _fetchPropertyList(),
        _fetchRequestedProps(),
        _fetchSentRequests(),
      ]);

      setState(() {
        isFetching = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isFetching = false;
      });
    }
  }

  Future<void> _fetchPropertyList() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('properties').get();
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

  Future<void> _fetchRequestedProps() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rental_requests')
          .where('ounerId', isEqualTo: uid) // Adjust query as needed
          .get();
      setState(() {
        requestedProps = querySnapshot.docs
            .map((doc) => RentModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching requested properties: $e');
    }
  }

  Future<void> _fetchSentRequests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rental_requests')
          .where('userId', isEqualTo: uid) // Adjust query as needed
          .get();
      setState(() {
        sentRequests = querySnapshot.docs
            .map((doc) => RentModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching sent requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Adjusted length for the new sent requests tab
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: const Text("Property Listing"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: Colors.black,
              child: TabBar(
                labelColor: Colors.redAccent,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
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
                  Tab(
                    icon: Icon(Icons.send),
                    text: "Sent Requests",
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            isFetching
                ? Center(child: CircularProgressIndicator())
                : PropertyListWidget(propertyRentList: propertyRentList),
            RequestedListWidget(requestedProps1: requestedProps),
            SentRequestsListWidget(sentRequests1: sentRequests),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.redAccent,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PropertyPost()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
