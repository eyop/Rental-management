import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:rental_management/models/property_model.dart';

class PropertyMapWidget extends StatefulWidget {
  final List<PropertyModel> properties;

  const PropertyMapWidget({Key? key, required this.properties})
      : super(key: key);

  @override
  _PropertyMapWidgetState createState() => _PropertyMapWidgetState();
}

class _PropertyMapWidgetState extends State<PropertyMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: GeoPoint(
        latitude: 9.0192,
        longitude: 38.7525,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      mapIsLoading: const Center(
        child: CircularProgressIndicator(),
      ),
      controller: _mapController,
      osmOption: OSMOption(
        enableRotationByGesture: true,
        showZoomController: true,
        showDefaultInfoWindow: true,
        zoomOption: const ZoomOption(
          initZoom: 12,
          minZoomLevel: 3,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: const RoadOption(
          roadColor: Colors.yellowAccent,
        ),
      ),
      onMapIsReady: (isReady) async {
        if (isReady) {
          await _addMarkers();
        }
      },
      onMapMoved: (region) => {},
    );
  }

  Future<void> _addMarkers() async {
    try {
      for (var property in widget.properties) {
        await _mapController.addMarker(
          GeoPoint(
            latitude: property.propertyLocation.latitude!,
            longitude: property.propertyLocation.longitude!,
          ),
          markerIcon: const MarkerIcon(
            icon: Icon(Icons.location_pin, color: Colors.red, size: 50),
          ),
          angle: 0, // Optional: Set angle if needed
          iconAnchor: IconAnchor(
            anchor: Anchor.top,
          ),
        );
      }
    } catch (e) {
      print('Error adding markers: $e');
    }
  }
}
