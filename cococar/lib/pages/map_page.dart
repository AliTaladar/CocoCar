import 'package:cococar/consts.dart';
import 'package:cococar/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng _sourceLocation = LatLng(45.5019, -73.5674);
  LatLng _destinationLocation = LatLng(45.4914, -73.5873);
  LatLng? _currentP = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then((_) => {
          getPolylinePoints().then((coordinates) => {
                generatePolylineFromPoints(coordinates),
              }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return _currentP == null
        ? const Scaffold(
            body: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 74, 175, 126),
                    backgroundColor: Colors.blueGrey,
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            body: Stack(children: [
              GoogleMap(
                onMapCreated: ((GoogleMapController controller) =>
                    _mapController.complete(controller)),
                initialCameraPosition: CameraPosition(
                  target: _sourceLocation,
                  zoom: 11,
                ),
                markers: {
                  Marker(
                      markerId: MarkerId("_currentLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _currentP!),
                  Marker(
                      markerId: MarkerId("_sourceLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _destinationLocation),
                  Marker(
                      markerId: MarkerId("_destinationLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _sourceLocation),
                },
                polylines: Set<Polyline>.of(polylines.values),
              ),
              Positioned(
                top: 50.0, // Adjust the positioning as needed
                left: 15.0,
                right: 15.0,
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(30.0), // Rounded corners
                    boxShadow: [
                      // ... your existing boxShadow properties
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildSearchButton(context, "Enter origin", true),
                      SizedBox(height: 8), // Spacing between buttons
                      _buildSearchButton(context, "Enter destination", false),
                    ],
                  ),
                ),
              ),
            ]),
          );
  }

  Widget _buildSearchButton(BuildContext context, String title, bool isOrigin) {
    return ElevatedButton(
      onPressed: () async {
        final searchedLocation =
            await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchPage(isOrigin: isOrigin),
        ));

        if (searchedLocation != null) {
          setState(() {
            if (isOrigin) {
              _sourceLocation = LatLng(
                  searchedLocation['latitude'], searchedLocation['longitude']);
            } else {
              _destinationLocation = LatLng(
                  searchedLocation['latitude'], searchedLocation['longitude']);
            }
            getLocationUpdates().then((_) => {
                  getPolylinePoints().then((coordinates) => {
                        generatePolylineFromPoints(coordinates),
                      }),
                });
          });

          print(
              "Selected location's latitude: ${searchedLocation['latitude']}, longitude: ${searchedLocation['longitude']}");
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: BorderSide(color: Colors.black12, width: 1),
        elevation: 0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: Colors.black87, fontSize: 16.0),
        ),
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 11,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    await Future.delayed(const Duration(seconds: 2));

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();

    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(_sourceLocation.latitude, _sourceLocation.longitude),
      PointLatLng(
          _destinationLocation.latitude, _destinationLocation.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print("error");
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}
