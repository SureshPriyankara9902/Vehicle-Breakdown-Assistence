


import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Assistants/assistant_methods.dart';
import '../global/global.dart';
import '../models/user_ride_request_information.dart';
import '../pushNotification/notification_dialog_box.dart';
import '../screens/new_trip_screen.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  Set<Marker> markersSet = {};
  StreamSubscription<DatabaseEvent>? _serviceStationsSubscription;
  StreamSubscription<Position>? streamSubscriptionPosition;

  static const CameraPosition _kSriLanka = CameraPosition(
    target: LatLng(7.8731, 80.7718),
    zoom: 8.0,
  );

  var geoLocator = Geolocator();
  int waitingRequestsCount = 0;
  LocationPermission? _locationPermission;
  String statusText = "Now Offline";
  Color buttonColor = Colors.white;
  bool isHelperActive = false;
  bool hasNewRideRequest = false;
  BitmapDescriptor? vehicleIcon;
  BitmapDescriptor? serviceStationIcon;

  bool _isDialogShowing = false;
  Completer<void> _navigationCompleter = Completer<void>()..complete();
  bool _showDeleteOption = false;
  List<Map<String, dynamic>> _userAddedStations = [];
  bool _isAddingServiceStation = false;
  LatLng? _selectedServiceStationLocation;
  bool _showServiceStationHelp = true;

  // Controllers for form fields
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _serviceDetailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentHelperInformation();
    helperIsOnlineNow().then((_) {
      listenForRideRequests();
      loadVehicleIcon();
      loadServiceStationIcon();
      _listenForServiceStations();
    });
  }

  @override
  void dispose() {
    _serviceStationsSubscription?.cancel();
    streamSubscriptionPosition?.cancel();
    _navigationCompleter.complete();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _serviceDetailsController.dispose();
    super.dispose();
  }

  Future<void> loadServiceStationIcon() async {
    serviceStationIcon = await _createResizedVehicleIcon(
      'images/servicest.png',
      70,
      80,
    );
    setState(() {});
  }

  Future<void> safeShowDialog(BuildContext context, Widget dialog) async {
    await _navigationCompleter.future;
    _navigationCompleter = Completer<void>();
    if (_isDialogShowing || !mounted) {
      _navigationCompleter.complete();
      return;
    }

    _isDialogShowing = true;
    try {
      await showDialog(
        context: context,
        builder: (context) => dialog,
      );
    } finally {
      _isDialogShowing = false;
      _navigationCompleter.complete();
    }
  }

  Future<void> loadVehicleIcon() async {
    vehicleIcon = await _createResizedVehicleIcon(
      'images/location_535137.png',
      80,
      80,
    );
    setState(() {});
  }

  Future<BitmapDescriptor> _createResizedVehicleIcon(
      String assetPath, int width, int height) async {
    final byteData = await rootBundle.load(assetPath);
    final Uint8List imageData = byteData.buffer.asUint8List();
    final ui.Image image = await decodeImageFromList(imageData);

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    final resizedImage = await pictureRecorder
        .endRecording()
        .toImage(width, height);
    final resizedImageData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(resizedImageData!.buffer.asUint8List());
  }



  void _fetchUserAddedStations() async {
    DataSnapshot snapshot = (await FirebaseDatabase.instance
        .ref()
        .child("serviceStations")
        .once()).snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> stations = snapshot.value as Map<dynamic, dynamic>;
      _userAddedStations = stations.entries
          .where((entry) => entry.value['addedBy'] == currentUser!.uid)
          .map((entry) => {
        'id': entry.key,
        'name': entry.value['name'],
        'address': entry.value['address'] ?? '',
        'phone': entry.value['phone'] ?? '',
        'serviceDetails': entry.value['serviceDetails'] ?? '',
        'latitude': entry.value['latitude'],
        'longitude': entry.value['longitude'],
      })
          .toList();
      setState(() {});
    }
  }

  void _showDraggableLocationSelectionDialog() {
    LatLng? selectedPosition;
    final Completer<GoogleMapController> _mapController = Completer();
    bool _isFirstLoad = true;
    double _currentZoom = 15.0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Select Location", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueGrey,
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(Icons.my_location),
                tooltip: 'Current Location',
                onPressed: () async {
                  if (helperCurrentPosition != null) {
                    final controller = await _mapController.future;
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          helperCurrentPosition!.latitude,
                          helperCurrentPosition!.longitude,
                        ),
                        _currentZoom,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _kSriLanka.target,
                  zoom: _currentZoom,
                ),
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                  if (helperCurrentPosition != null && _isFirstLoad) {
                    _isFirstLoad = false;
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          helperCurrentPosition!.latitude,
                          helperCurrentPosition!.longitude,
                        ),
                        _currentZoom,
                      ),
                    );
                  }
                },
                markers: selectedPosition != null
                    ? {
                  Marker(
                    markerId: MarkerId('selected_location'),
                    position: selectedPosition!,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        selectedPosition = newPosition;
                      });
                    },
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                }
                    : {},
                onTap: (position) {
                  setState(() {
                    selectedPosition = position;
                  });
                },
                onCameraMove: (position) {
                  _currentZoom = position.zoom;
                },
                zoomControlsEnabled: false,
              ),

              IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 48,
                      ),
                      if (selectedPosition != null)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            "${selectedPosition!.latitude.toStringAsFixed(6)}, ${selectedPosition!.longitude.toStringAsFixed(6)}",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Positioned(
                right: 20,
                bottom: 100,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoomIn',
                      onPressed: () async {
                        final controller = await _mapController.future;
                        controller.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                        _currentZoom += 1;
                      },
                      child: Icon(Icons.add),
                    ),
                    SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'zoomOut',
                      onPressed: () async {
                        final controller = await _mapController.future;
                        controller.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                        _currentZoom -= 1;
                      },
                      child: Icon(Icons.remove),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedPosition != null) {
                          Navigator.of(context).pop(selectedPosition);
                        } else {
                          Fluttertoast.showToast(
                            msg: "Please select a location first",
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text("Confirm"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedServiceStationLocation = value;
          markersSet.add(
            Marker(
              markerId: MarkerId('selected_location'),
              position: value,
              icon: serviceStationIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(title: "Selected Location"),
            ),
          );
        });
        _showAddServiceStationDialog();
      }
    });
  }

  void _handleMapTap(LatLng tappedPoint) {
    if (_isAddingServiceStation) {
      setState(() {
        _selectedServiceStationLocation = tappedPoint;
        markersSet.removeWhere((marker) => marker.markerId.value == 'temp_service');
        markersSet.add(
          Marker(
            markerId: MarkerId('temp_service'),
            position: tappedPoint,
            icon: serviceStationIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: "Selected Location"),
          ),
        );
      });

      Fluttertoast.showToast(
        msg: "Location selected! Continue with form submission.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  void _toggleDeleteOption() {
    setState(() {
      _showDeleteOption = !_showDeleteOption;
      if (_showDeleteOption) {
        _fetchUserAddedStations();
      }
    });
  }

  Future<void> _deleteServiceStation(String stationId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this service station?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      await FirebaseDatabase.instance
          .ref()
          .child("serviceStations")
          .child(stationId)
          .remove();

      Fluttertoast.showToast(
        msg: "Service station removed successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      _fetchUserAddedStations();
    }
  }

  void _listenForServiceStations() {
    _serviceStationsSubscription = FirebaseDatabase.instance
        .ref()
        .child("serviceStations")
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final stations = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          markersSet.removeWhere((marker) => marker.markerId.value.startsWith('service_'));
          stations.forEach((key, value) {
            final stationData = Map<String, dynamic>.from(value);
            markersSet.add(
              Marker(
                markerId: MarkerId('service_$key'),
                position: LatLng(
                  stationData['latitude'] as double,
                  stationData['longitude'] as double,
                ),
                icon: serviceStationIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: stationData['name'] as String? ?? 'Service Station',
                  snippet: stationData['serviceDetails'] as String? ?? stationData['address'] as String? ?? '',
                ),
                onTap: () {
                  _showServiceStationDetailsDialog(stationData);
                },
              ),
            );
          });
        });
      }
    });
  }

  void _showServiceStationDetailsDialog(Map<String, dynamic> stationData) {
    safeShowDialog(
      context,
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.build_circle, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                Text(
                  stationData['name'] ?? 'Service Station',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.location_on, stationData['address'] ?? 'Address not provided'),
              SizedBox(height: 10),
              _buildDetailRow(Icons.phone, stationData['phone'] ?? 'Phone not provided'),
              SizedBox(height: 10),
              _buildDetailRow(Icons.directions_car, stationData['serviceDetails'] ?? 'Service details not provided'),

              if (stationData['addedBy'] == currentUser!.uid)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    "You added this station",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Close",
              style: TextStyle(color: Colors.red),
            ),
          ),
          if (stationData['addedBy'] == currentUser!.uid)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editServiceStation({
                  'id': stationData['id'],
                  'name': stationData['name'],
                  'address': stationData['address'],
                  'phone': stationData['phone'],
                  'serviceDetails': stationData['serviceDetails'],
                  'latitude': stationData['latitude'],
                  'longitude': stationData['longitude'],
                });
              },
              child: Text(
                "Edit",
                style: TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }


  void _showNewHelperTutorial() {
    safeShowDialog(
      context,
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Welcome"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "As a helper, you can add service stations to the map to help users find assistance.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "To add a service station:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("1. Tap the + button at the bottom right"),
              Text("2. Tap on the map to select a location"),
              Text("3. Fill in the details about the service station"),
              Text("4. Save your changes"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _showServiceStationHelp = false;
              });
            },
            child: Text("Don't show again"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isAddingServiceStation = true;
              });
              _showAddServiceStationDialog();
            },
            child: Text("Add Service Station Now"),
          ),
        ],
      ),
    );
  }

  void _showAddServiceStationDialog() {
    safeShowDialog(
      context,
      AlertDialog(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_business, color: Colors.blue),
                SizedBox(width: 10),
                Text("Add Service Station", style: TextStyle(color: Colors.black)),
              ],
            ),
            Divider(),
            Text(
              "Step 1: Fill out the form",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Station Name",
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: "Address",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _serviceDetailsController,
                  decoration: InputDecoration(
                    labelText: "Service Details",
                    prefixIcon: Icon(Icons.directions_car),
                    border: OutlineInputBorder(),
                    hintText: "e.g. Towing, Tire repair, Battery jumpstart",
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe services offered';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          "Step 2: Select Location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _selectedServiceStationLocation == null
                                  ? Icons.location_off
                                  : Icons.location_on,
                              color: _selectedServiceStationLocation == null
                                  ? Colors.grey
                                  : Colors.green,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedServiceStationLocation == null
                                    ? "Tap below to select location"
                                    : "Location selected at ${_selectedServiceStationLocation!.latitude.toStringAsFixed(4)}, ${_selectedServiceStationLocation!.longitude.toStringAsFixed(4)}",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: _selectedServiceStationLocation == null
                                      ? Colors.grey
                                      : Colors.green,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.map, color: Colors.red),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showDraggableLocationSelectionDialog();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFormData();
              Navigator.of(context).pop();
            },
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && _selectedServiceStationLocation != null) {
                await _saveServiceStation();
                Navigator.of(context).pop();
              } else if (_selectedServiceStationLocation == null) {
                Fluttertoast.showToast(
                  msg: "Please select a location on the map",
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            child: Text("Save", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _clearFormData() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _serviceDetailsController.clear();
    _selectedServiceStationLocation = null;
    markersSet.removeWhere((marker) => marker.markerId.value == 'temp_service');
    setState(() {
      _isAddingServiceStation = false;
    });
  }

  Future<void> _saveServiceStation() async {
    DatabaseReference serviceStationsRef = FirebaseDatabase.instance
        .ref()
        .child("serviceStations")
        .push();

    Map<String, dynamic> serviceStationData = {
      "id": serviceStationsRef.key,
      "name": _nameController.text,
      "address": _addressController.text,
      "phone": _phoneController.text,
      "serviceDetails": _serviceDetailsController.text,
      "latitude": _selectedServiceStationLocation!.latitude,
      "longitude": _selectedServiceStationLocation!.longitude,
      "addedBy": currentUser!.uid,
      "timestamp": ServerValue.timestamp,
    };

    await serviceStationsRef.set(serviceStationData);

    _clearFormData();

    Fluttertoast.showToast(
      msg: "Service station added successfully",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  Future<void> _updateServiceStation(String stationId) async {
    if (_selectedServiceStationLocation == null) {
      Fluttertoast.showToast(
        msg: "Please select a location first",
        backgroundColor: Colors.red,
      );
      return;
    }

    DatabaseReference serviceStationsRef = FirebaseDatabase.instance
        .ref()
        .child("serviceStations")
        .child(stationId);

    Map<String, dynamic> serviceStationData = {
      "name": _nameController.text,
      "address": _addressController.text,
      "phone": _phoneController.text,
      "serviceDetails": _serviceDetailsController.text,
      "latitude": _selectedServiceStationLocation!.latitude,
      "longitude": _selectedServiceStationLocation!.longitude,
      "timestamp": ServerValue.timestamp,
    };

    try {
      await serviceStationsRef.update(serviceStationData);
      Fluttertoast.showToast(
        msg: "Service station updated successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _fetchUserAddedStations();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _editServiceStation(Map<String, dynamic> station) {
    _nameController.text = station['name'] ?? '';
    _addressController.text = station['address'] ?? '';
    _phoneController.text = station['phone'] ?? '';
    _serviceDetailsController.text = station['serviceDetails'] ?? '';
    _selectedServiceStationLocation = LatLng(
        station['latitude'],
        station['longitude']
    );

    if (_selectedServiceStationLocation != null) {
      markersSet.add(
        Marker(
          markerId: MarkerId('edit_location'),
          position: _selectedServiceStationLocation!,
          icon: serviceStationIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: "Current Location"),
        ),
      );
    }

    safeShowDialog(
      context,
      AlertDialog(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 10),
                Text("Update Service Station"),
              ],
            ),
            Divider(),
            Text(
              "Step 1: Update the form",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Station Name",
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: "Address",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _serviceDetailsController,
                  decoration: InputDecoration(
                    labelText: "Service Details",
                    prefixIcon: Icon(Icons.directions_car),
                    border: OutlineInputBorder(),
                    hintText: "e.g. Towing, Tire repair, Battery jumpstart",
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe services offered';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          "Step 2: Select Location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _selectedServiceStationLocation == null
                                  ? Icons.location_off
                                  : Icons.location_on,
                              color: _selectedServiceStationLocation == null
                                  ? Colors.grey
                                  : Colors.green,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedServiceStationLocation == null
                                    ? "Tap below to select location"
                                    : "Location selected at ${_selectedServiceStationLocation!.latitude.toStringAsFixed(4)}, ${_selectedServiceStationLocation!.longitude.toStringAsFixed(4)}",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: _selectedServiceStationLocation == null
                                      ? Colors.grey
                                      : Colors.green,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.map, color: Colors.red),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showEditLocationDialog(station);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFormData();
              Navigator.of(context).pop();
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey[800])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  _selectedServiceStationLocation != null) {
                await _updateServiceStation(station['id']);
                Navigator.of(context).pop();
              } else if (_selectedServiceStationLocation == null) {
                Fluttertoast.showToast(
                  msg: "Please select a location on the map",
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            child: Text("Update", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(Map<String, dynamic> station) {
    LatLng selectedPosition = LatLng(
        station['latitude'],
        station['longitude']
    );
    final Completer<GoogleMapController> _mapController = Completer();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Update Location", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedPosition,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                },
                markers: {
                  Marker(
                    markerId: MarkerId('edit_location'),
                    position: selectedPosition,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      selectedPosition = newPosition;
                    },
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
                },
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_pin, color: Colors.red, size: 48),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        "${selectedPosition.latitude.toStringAsFixed(6)}, ${selectedPosition.longitude.toStringAsFixed(6)}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedServiceStationLocation = selectedPosition;
                        });
                        Navigator.pop(context, selectedPosition);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("Save Location"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedServiceStationLocation = value;
        });
        _editServiceStation(station);
      }
    });
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateHelperPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    helperCurrentPosition = cPosition;
    LatLng latLngPositions = LatLng(cPosition.latitude, cPosition.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPositions, zoom: 15);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    await AssistantsMethods.searchAddressForGeographicCoordinates(cPosition, context);
    AssistantsMethods.readHelperRatings(context);

    Future.delayed(Duration(seconds: 1), () {
      if (_showServiceStationHelp) {
        _showNewHelperTutorial();
      }
    });
  }

  readCurrentHelperInformation() async {
    currentUser = firebaseAuth.currentUser;
    FirebaseDatabase.instance.ref().child("helpers").child(currentUser!.uid).once().then((snap) {
      if (snap.snapshot.value != null) {
        onlineHelperData.id = (snap.snapshot.value as Map)["id"];
        onlineHelperData.name = (snap.snapshot.value as Map)["name"];
        onlineHelperData.phone = (snap.snapshot.value as Map)["phone"];
        onlineHelperData.email = (snap.snapshot.value as Map)["email"];
        onlineHelperData.address = (snap.snapshot.value as Map)["address"];
        onlineHelperData.ratings = (snap.snapshot.value as Map)["ratings"];
        onlineHelperData.vehicle_model = (snap.snapshot.value as Map)["vehicle_details"]["vehicle_model"];
        onlineHelperData.vehicle_number = (snap.snapshot.value as Map)["vehicle_details"]["vehicle_number"];
        onlineHelperData.vehicle_color = (snap.snapshot.value as Map)["vehicle_details"]["vehicle_color"];
        helperVehicleType = (snap.snapshot.value as Map)["vehicle_details"]["vehicle_type"];
      }
    });
    AssistantsMethods.readHelperRatings(context);
  }

  void listenForRideRequests() {
    FirebaseDatabase.instance.ref().child("All Ride Requests").onChildAdded.listen((event) async {
      if (event.snapshot.value != null && isHelperActive) {
        Map<dynamic, dynamic> rideRequestData = event.snapshot.value as Map<dynamic, dynamic>;
        if (rideRequestData["helperId"] == "waiting") {
          setState(() {
            hasNewRideRequest = true;
            waitingRequestsCount++;
            addRideMarker(rideRequestData);
          });
        }
      }
    });

    FirebaseDatabase.instance.ref().child("All Ride Requests").onChildRemoved.listen((event) {
      if (isHelperActive) {
        setState(() {
          waitingRequestsCount--;
          hasNewRideRequest = waitingRequestsCount > 0;
          markersSet.removeWhere((marker) => marker.markerId.value == event.snapshot.key);
        });
      }
    });

    FirebaseDatabase.instance.ref().child("All Ride Requests").onChildChanged.listen((event) {
      if (event.snapshot.value != null && isHelperActive) {
        Map<dynamic, dynamic> rideRequestData = event.snapshot.value as Map<dynamic, dynamic>;
        if (rideRequestData["status"] == "ended" || rideRequestData["status"] == "accepted") {
          setState(() {
            waitingRequestsCount--;
            hasNewRideRequest = waitingRequestsCount > 0;
            markersSet.removeWhere((marker) => marker.markerId.value == event.snapshot.key);
          });
        }
      }
    });
  }

  void addRideMarker(Map<dynamic, dynamic> rideRequestData) {
    if (rideRequestData["origin"] != null) {
      LatLng originLatLng = LatLng(
        double.parse(rideRequestData["origin"]["latitude"].toString()),
        double.parse(rideRequestData["origin"]["longitude"].toString()),
      );

      Marker marker = Marker(
        markerId: MarkerId(rideRequestData["rideRequestId"] ?? DateTime.now().toString()),
        position: originLatLng,
        icon: vehicleIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: "Pickup Location",
          snippet: rideRequestData["originAddress"],
        ),
        onTap: () {
          safeShowDialog(
            context,
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "User Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "${rideRequestData["userName"]}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "${rideRequestData["userPhone"]}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.trip_origin, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "${rideRequestData["originAddress"]}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        markersSet.add(marker);
      });
    }
  }

  void showAllRideRequestsDialog() async {
    if (_isDialogShowing || !mounted) return;

    DatabaseReference helperRef = FirebaseDatabase.instance.ref().child("helpers").child(firebaseAuth.currentUser!.uid);
    DataSnapshot helperSnapshot = (await helperRef.child("vehicle_details").once()).snapshot;

    if (helperSnapshot.value != null) {
      Map<dynamic, dynamic> helperData = helperSnapshot.value as Map<dynamic, dynamic>;
      String helperVehicleType = helperData["vehicle_type"] ?? "";

      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .orderByChild("helperId")
          .equalTo("waiting")
          .once()
          .then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> rideRequests = event.snapshot.value as Map<dynamic, dynamic>;
          List<UserRideRequestInformation> rideRequestList = [];
          rideRequests.forEach((key, value) {
            if (value["vehicleType"] == helperVehicleType) {
              UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
              userRideRequestDetails.originLatLng = LatLng(
                double.parse(value["origin"]["latitude"]),
                double.parse(value["origin"]["longitude"]),
              );
              userRideRequestDetails.originAddress = value["originAddress"];
              userRideRequestDetails.destinationLatLng = LatLng(
                double.parse(value["destination"]["latitude"]),
                double.parse(value["destination"]["longitude"]),
              );
              userRideRequestDetails.destinationAddress = value["destinationAddress"];
              userRideRequestDetails.userName = value["userName"];
              userRideRequestDetails.userPhone = value["userPhone"];
              userRideRequestDetails.rideRequestId = key;
              userRideRequestDetails.vehicleType = value["vehicleType"];
              rideRequestList.add(userRideRequestDetails);
            }
          });

          if (rideRequestList.isNotEmpty) {
            safeShowDialog(
              context,
              AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.white,
                title: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Ride Requests",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                content: Container(
                  width: double.maxFinite,
                  constraints: BoxConstraints(
                    maxHeight: rideRequestList.length > 3 ? 300 : rideRequestList.length * 100.0,
                  ),
                  child: rideRequestList.isNotEmpty
                      ? Scrollbar(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: rideRequestList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(Icons.person_pin_circle, color: Colors.green),
                            title: Text(
                              rideRequestList[index].userName!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("From: ${rideRequestList[index].originAddress}"),
                                Text("To: ${rideRequestList[index].destinationAddress}"),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                            onTap: () {
                              Navigator.of(context).pop();
                              safeShowDialog(
                                context,
                                NotificationDialogBox(
                                  userRideRequestDetails: rideRequestList[index],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Text(
                      "No Ride Requests Available",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "No ride requests for your vehicle type",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "No active ride requests",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      });
    } else {
      Fluttertoast.showToast(
        msg: "Please register your vehicle type first",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  helperIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    helperCurrentPosition = pos;
    Geofire.initialize("activeHelpers");
    Geofire.setLocation(currentUser!.uid, pos.latitude, pos.longitude);
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("helpers")
        .child(currentUser!.uid)
        .child("newRideStatus");
    ref.set("Active");
    ref.onValue.listen((event) {});
  }

  updateHelperLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      if (isHelperActive) {
        helperCurrentPosition = position;
        Geofire.setLocation(currentUser!.uid, position.latitude, position.longitude);
        LatLng latLng = LatLng(position.latitude, position.longitude);
        newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });
  }

  helperIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("helpers")
        .child(currentUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 50),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          markers: markersSet,
          initialCameraPosition: _kSriLanka,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            locateHelperPosition();
          },
          onTap: _handleMapTap,
        ),
        statusText != "Now Online"
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        )
            : Container(),
        Positioned(
          top: statusText != "Now Online" ? MediaQuery.of(context).size.height * 0.45 : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (!isHelperActive) {
                    helperIsOnlineNow();
                    updateHelperLocationAtRealTime();
                    setState(() {
                      statusText = "Now Online";
                      isHelperActive = true;
                      buttonColor = Colors.green;
                    });
                  } else {
                    helperIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isHelperActive = false;
                      buttonColor = Colors.white;
                    });
                    Fluttertoast.showToast(msg: "You are offline now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  side: BorderSide(
                    color: isHelperActive ? Colors.green : Colors.red,
                    width: 1,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: statusText != "Now Online"
                    ? Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
                    : Icon(
                  Icons.phonelink_ring,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),

        if (isHelperActive)
          Positioned(
            top: 110,
            right: 20,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 0.5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_active,
                      color: hasNewRideRequest ? Colors.red : Colors.green,
                      size: 30,
                    ),
                    onPressed: () {
                      if (hasNewRideRequest) {
                        showAllRideRequestsDialog();
                      } else {
                        Fluttertoast.showToast(
                          msg: "No new ride requests",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ),
                ),
                if (waitingRequestsCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$waitingRequestsCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        if (isHelperActive)
          Positioned(
            bottom: 200,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.info_outline, color: Colors.red),
                tooltip: 'Help',
                onPressed: () {
                  _showNewHelperTutorial();
                },
              ),
            ),
          ),

        if (isHelperActive)
          Positioned(
            bottom: 130,
            right: 20,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _isAddingServiceStation ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _isAddingServiceStation ? 16.0 : 0,
                  vertical: _isAddingServiceStation ? 8.0 : 0,
                ),
                child: _isAddingServiceStation
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Tap on map",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAddingServiceStation = false;
                          _selectedServiceStationLocation = null;
                          markersSet.removeWhere((marker) =>
                          marker.markerId.value == 'temp_service');
                        });
                      },
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                )
                    : IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingServiceStation = true;
                    });

                    Fluttertoast.showToast(
                      msg: "Tap on the map to select service station location",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                    );

                    _showAddServiceStationDialog();
                  },
                  icon: Icon(Icons.add_business, color: Colors.white),
                  tooltip: 'Add Service Station',
                ),
              ),
            ),
          ),

        if (_isAddingServiceStation)
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  "SERVICE STATION MODE: Tap on map to select location",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        if (isHelperActive)
          Positioned(
            bottom: 280,
            right: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Circular build button
                Container(
                  padding: EdgeInsets.all(0.2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,

                  ),
                  child: IconButton(
                    icon: Icon(Icons.build, color: Colors.black, size: 24),
                    onPressed: _toggleDeleteOption,
                    tooltip: 'Delete Service Stations',
                  ),
                ),

                // Count badge positioned to top-right
                Positioned(
                  top: -8,
                  right: -3,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(100),

                    ),
                    child: Text(
                      "${markersSet.where((marker) => marker.markerId.value.startsWith('service_')).length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (_showDeleteOption && _userAddedStations.isNotEmpty)
          Positioned(
            bottom: 130,
            right: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Center(
                        child: Text(
                          "Your Service Stations",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _userAddedStations.length,
                          itemBuilder: (context, index) {
                            final station = _userAddedStations[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Icon(Icons.build_circle, color: Colors.blue, size: 30),
                                title: Center(
                                  child: Text(
                                    station['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue, size: 24),
                                      onPressed: () => _editServiceStation(station),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red, size: 24),
                                      onPressed: () => _deleteServiceStation(station['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _showDeleteOption = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (_showDeleteOption && _userAddedStations.isEmpty)
          Positioned(
            bottom: 130,
            right: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "You haven't added any service stations yet",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}