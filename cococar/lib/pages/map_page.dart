import 'package:cococar/consts.dart';
import 'package:cococar/pages/search_page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart'
    as PermissionHandler;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  Set<Marker> mapMarkers = Set();

  LatLng? _sourceLocation = null;
  LatLng? _destinationLocation = null;
  LatLng? _currentP = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return _currentP == null
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 74, 175, 126),
                backgroundColor: Colors.blueGrey,
              ),
            ),
          )
        : Scaffold(
            body: Stack(children: [
              GoogleMap(
                onMapCreated: ((GoogleMapController controller) =>
                    _mapController.complete(controller)),
                initialCameraPosition: CameraPosition(
                  target: _currentP!,
                  zoom: 11,
                ),
                markers: mapMarkers,
                // {
                //   Marker(
                //       markerId: MarkerId("_currentLocation"),
                //       icon: BitmapDescriptor.defaultMarker,
                //       position: _currentP!),
                //   Marker(
                //       markerId: MarkerId("_sourceLocation"),
                //       icon: BitmapDescriptor.defaultMarker,
                //       position: _destinationLocation),
                //   Marker(
                //       markerId: MarkerId("_destinationLocation"),
                //       icon: BitmapDescriptor.defaultMarker,
                //       position: _sourceLocation),
                // },
                polylines: Set<Polyline>.of(polylines.values),
              ),
              Positioned(
                top: 50.0,
                left: 15.0,
                right: 15.0,
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
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

              mapMarkers.add(
                Marker(
                    markerId: const MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _sourceLocation!),
              );
            } else {
              _destinationLocation = LatLng(
                  searchedLocation['latitude'], searchedLocation['longitude']);
              mapMarkers.add(
                Marker(
                    markerId: const MarkerId("_destinationLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _destinationLocation!),
              );
            }
            getLocationUpdates().then((_) => {
                  if (_sourceLocation != null && _destinationLocation != null)
                    {
                      getPolylinePoints().then((coordinates) =>
                          {generatePolylineFromPoints(coordinates)})
                    }
                });
            if (_sourceLocation != null && _destinationLocation != null) {
              Map<String, dynamic> locationsJson = {
                "sourceLocation": {
                  "latitude": _sourceLocation!.latitude,
                  "longitude": _sourceLocation!.longitude,
                },
                "destinationLocation": {
                  "latitude": _destinationLocation!.latitude,
                  "longitude": _destinationLocation!.longitude,
                }
              };
              writeJson(locationsJson).then((_) {
                // Optionally, handle confirmation of data saved
                print("Locations saved successfully");
              }).catchError((error) {
                // Handle any errors here
                print("Error saving locations: $error");
              });
            }
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
          mapMarkers.add(Marker(
              markerId: const MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _currentP!));
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAPS_API_KEY,
      PointLatLng(_sourceLocation!.latitude, _sourceLocation!.longitude),
      PointLatLng(
          _destinationLocation!.latitude, _destinationLocation!.longitude),
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print("PATH IS HERE");
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("localfile");
    print(path);

    await checkIfPathExists(path);
    if (await _requestStoragePermissions(
            PermissionHandler.Permission.storage) ==
        true) {
      print("Permission is granted");
    } else {
      print("Permission is not granted");
    }

    return File('$path/points.json');
  }

  Future<void> checkIfPathExists(String path) async {
    final file = File(path);

    bool exists = await file.exists();

    if (exists) {
      print("The path exists.");
    } else {
      print("The path does not exist.");
    }
  }

  Future<bool> _requestStoragePermissions(
      PermissionHandler.Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re =
          await PermissionHandler.Permission.manageExternalStorage.request();
      if (re.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future<File> writeJson(Map<String, dynamic> jsonMap) async {
    final file = await _localFile;

    String jsonString = json.encode(jsonMap);

    return file.writeAsString(jsonString);
  }

  Future<Map<String, dynamic>> readJson() async {
    try {
      final file = await _localFile;

      String jsonString = await file.readAsString();

      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap;
    } catch (e) {
      return {};
    }
  }
}
