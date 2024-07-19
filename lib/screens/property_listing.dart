import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rental_management/models/property_model.dart';
import 'package:rental_management/models/rent_model.dart';
import 'package:rental_management/providers/authentication_provider.dart';
import 'package:rental_management/screens/aboutpage_screen.dart';
import 'package:rental_management/screens/privacyPolicy_Screen.dart';
import 'package:rental_management/screens/profileScreen.dart';
import 'package:rental_management/screens/property_post.dart';
import 'package:rental_management/widgets/property_ListWidget.dart';
import 'package:rental_management/widgets/recevedRequest_ListWidget.dart';
import 'package:rental_management/widgets/sentRequests_ListWidget.dart';

class PropertyListing extends StatefulWidget {
  const PropertyListing({super.key});

  @override
  State<PropertyListing> createState() => _PropertyListingState();
}

class _PropertyListingState extends State<PropertyListing>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late TabController _tabController;
  bool isFetching = false;
  String? uid;
  String searchQuery = '';
  String sortOption = 'price';
  bool isAscending = true;

  List<PropertyModel> propertyRentList = [];
  List<PropertyModel> filteredPropertyList = [];
  List<RentModel> requestedProps1 = [];
  List<RentModel> sentRequests1 = [];

  @override
  void initState() {
    super.initState();
    uid = context.read<AuthenticationProvider>().uid;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isFetching = true;
      });
      // Fetch property lists concurrently using AuthenticationProvider
      await Future.wait([
        _fetchProperties(),
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

  Future<void> _fetchProperties() async {
    try {
      List<PropertyModel> properties =
          await context.read<AuthenticationProvider>().fetchProperties();
      setState(() {
        propertyRentList = properties;
        _filterAndSortProperties();
      });
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }

  Future<void> _fetchRequestedProps() async {
    try {
      List<RentModel> requestedProps =
          await context.read<AuthenticationProvider>().fetchRequestProps();
      setState(() {
        requestedProps1 = requestedProps;
      });
    } catch (e) {
      print('Error fetching requested properties: $e');
    }
  }

  Future<void> _fetchSentRequests() async {
    try {
      List<RentModel> sentRequests =
          await context.read<AuthenticationProvider>().fetchSentRequests();
      setState(() {
        sentRequests1 = sentRequests;
      });
    } catch (e) {
      print('Error fetching sent requests: $e');
    }
  }

  Future<void> _refreshData() async {
    await _fetchData();
  }

  void _filterAndSortProperties() {
    filteredPropertyList = propertyRentList
        .where((property) =>
            property.price.toLowerCase().contains(searchQuery.toLowerCase()) ||
            property.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
        .toList();

    if (sortOption == 'price') {
      filteredPropertyList.sort((a, b) => isAscending
          ? a.price.compareTo(b.price)
          : b.price.compareTo(a.price));
    } else if (sortOption == 'type') {
      filteredPropertyList.sort((a, b) => isAscending
          ? a.propertyType!.compareTo(b.propertyType!)
          : b.propertyType!.compareTo(a.propertyType!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("RentEase"),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent,
            tabs: const [
              Tab(icon: Icon(Icons.list), text: "Properties"),
              Tab(icon: Icon(Icons.request_page), text: "Incoming Requests"),
              Tab(icon: Icon(Icons.send), text: "Sent Requests"),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, letterSpacing: 1.5),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.cabin),
                title: const Text(
                  'Properties Posted',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                subtitle: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('properties')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    return Text('${snapshot.data!.docs.length}');
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check),
                title: const Text(
                  'Properties Rented',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                subtitle: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rental_requests')
                      .where('status', isEqualTo: 'accepted')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }
                    return Text('${snapshot.data!.docs.length}');
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  'Profile',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrivacyPolicyScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text(
                  'About',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1),
                ),
                onTap: () {
                  context.read<AuthenticationProvider>().logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              _filterAndSortProperties();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.all(0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: sortOption,
                        items: const [
                          DropdownMenuItem(
                            value: 'price',
                            child: Text('Sort by Price'),
                          ),
                          DropdownMenuItem(
                            value: 'type',
                            child: Text('Sort by Type'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sortOption = value!;
                            _filterAndSortProperties();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          setState(() {
                            isAscending = !isAscending;
                            _filterAndSortProperties();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: isFetching
                        ? const Center(child: CircularProgressIndicator())
                        : PropertyListWidget(
                            propertyRentList: filteredPropertyList),
                  ),
                ),
              ],
            ),
            RefreshIndicator(
              onRefresh: _refreshData,
              child: RecevedRequestListWidget(requestedProps1: requestedProps1),
            ),
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SentRequestsListWidget(sentRequests1: sentRequests1),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PropertyPost()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
