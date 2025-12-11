import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:custom_info_window/custom_info_window.dart';

class MapViewScreen extends StatefulWidget {
  final List<dynamic> products;

  const MapViewScreen({Key? key, required this.products}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Position? _currentPosition;
  String _currentAddress = '';
  Set<Marker> _markers = {};
  double _filterRadius = 10.0; // in kilometers
  bool _isMapLoading = true;
  bool _isLocationLoading = true;
  bool _showListView = false;

  // Default center on US if location not available
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.0902, -95.7129),
    zoom: 4.0,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLocationLoading = true;
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        _showLocationDisabledDialog();
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          _showPermissionDeniedDialog();
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        _showPermissionDeniedDialog();
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12.0,
        );
        _isLocationLoading = false;
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Add product markers
      _addProductMarkers();

      // Get address from the location
      _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
      _showErrorDialog('Could not get your location. Please try again.');
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
        });
      }
    } catch (e) {}
  }

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('currentLocation'),
            position: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: 'Your Location',
              snippet:
                  _currentAddress.isEmpty
                      ? 'Current Location'
                      : _currentAddress,
            ),
          ),
        );
      });
    }
  }

  void _addProductMarkers() {
    for (var product in widget.products) {
      // Skip if product doesn't have location data
      if (product['latitude'] == null || product['longitude'] == null) {
        continue;
      }

      // Parse location
      double lat = double.tryParse(product['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(product['longitude'].toString()) ?? 0.0;

      // Skip invalid coordinates
      if (lat == 0.0 && lng == 0.0) {
        continue;
      }

      // Skip if outside filter radius (if current location is available)
      if (_currentPosition != null) {
        double distanceInKm =
            Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              lat,
              lng,
            ) /
            1000; // Convert meters to kilometers

        if (distanceInKm > _filterRadius) {
          continue;
        }
      }

      // Create marker
      final markerId = MarkerId(product['id'].toString());
      final marker = Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        onTap: () {
          _customInfoWindowController.addInfoWindow!(
            _buildInfoWindow(product),
            LatLng(lat, lng),
          );
        },
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  void _updateFilterRadius(double radius) {
    setState(() {
      _filterRadius = radius;
      _markers.clear();
    });

    _addCurrentLocationMarker();
    _addProductMarkers();
  }

  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Location Services Disabled'),
            content: Text(
              'Please enable location services to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Location Permission Denied'),
            content: Text(
              'Please enable location permissions in your device settings to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoWindow(dynamic product) {
    String title = product['title'] ?? 'Unnamed Item';
    String price = '\$${product['price']}';
    String image = product['image'] ?? '';
    String distance = '';

    // Calculate distance if current location is available
    if (_currentPosition != null) {
      double lat = double.tryParse(product['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(product['longitude'].toString()) ?? 0.0;

      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        lat,
        lng,
      );

      // Format distance
      if (distanceInMeters < 1000) {
        distance = '${distanceInMeters.toStringAsFixed(0)} m away';
      } else {
        double distanceInKm = distanceInMeters / 1000;
        distance = '${distanceInKm.toStringAsFixed(1)} km away';
      }
    }

    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                // Product image
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image:
                          image.isNotEmpty
                              ? NetworkImage(image)
                              : AssetImage('assets/slicing/placeholder.jpg')
                                  as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          price,
                          style: TextStyle(
                            color: darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (distance.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  distance,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // Navigate to product details
                            // Get.to(
                            //   () => RentNowScreen(
                            //     productId: product['id'].toString(),
                            //   ),
                            // );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xffFEB038),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
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
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Distance',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: darkBlue),
                SizedBox(width: 8),
                Expanded(
                  child:
                      _currentAddress.isEmpty
                          ? Text(
                            'Loading location...',
                            style: TextStyle(fontSize: 14),
                          )
                          : Text(
                            _currentAddress,
                            style: TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('1km', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _filterRadius,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    label: '${_filterRadius.round()} km',
                    onChanged: (value) {
                      setState(() {
                        _filterRadius = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _updateFilterRadius(value);
                    },
                    activeColor: darkBlue,
                  ),
                ),
                Text('50km', style: TextStyle(fontSize: 12)),
              ],
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Show rentals within ${_filterRadius.round()} km',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyItems() {
    // Filter products by distance
    List<dynamic> nearbyProducts = [];
    if (_currentPosition != null) {
      nearbyProducts =
          widget.products.where((product) {
            if (product['latitude'] == null || product['longitude'] == null) {
              return false;
            }

            double lat = double.tryParse(product['latitude'].toString()) ?? 0.0;
            double lng =
                double.tryParse(product['longitude'].toString()) ?? 0.0;

            if (lat == 0.0 && lng == 0.0) {
              return false;
            }

            double distanceInKm =
                Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  lat,
                  lng,
                ) /
                1000;

            return distanceInKm <= _filterRadius;
          }).toList();
    }

    // Sort by distance
    if (_currentPosition != null) {
      nearbyProducts.sort((a, b) {
        double latA = double.tryParse(a['latitude'].toString()) ?? 0.0;
        double lngA = double.tryParse(a['longitude'].toString()) ?? 0.0;
        double latB = double.tryParse(b['latitude'].toString()) ?? 0.0;
        double lngB = double.tryParse(b['longitude'].toString()) ?? 0.0;

        double distanceA = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          latA,
          lngA,
        );

        double distanceB = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          latB,
          lngB,
        );

        return distanceA.compareTo(distanceB);
      });
    }

    return Container(
      height: 300,
      child:
          nearbyProducts.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No items found nearby',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try increasing the search radius',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: nearbyProducts.length,
                itemBuilder: (context, index) {
                  final product = nearbyProducts[index];

                  // Calculate distance
                  String distance = '';
                  if (_currentPosition != null) {
                    double lat =
                        double.tryParse(product['latitude'].toString()) ?? 0.0;
                    double lng =
                        double.tryParse(product['longitude'].toString()) ?? 0.0;

                    double distanceInMeters = Geolocator.distanceBetween(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      lat,
                      lng,
                    );

                    if (distanceInMeters < 1000) {
                      distance =
                          '${distanceInMeters.toStringAsFixed(0)} m away';
                    } else {
                      double distanceInKm = distanceInMeters / 1000;
                      distance = '${distanceInKm.toStringAsFixed(1)} km away';
                    }
                  }

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigate to product details
                        // Get.to(
                        //   () => RentNowScreen(
                        //     productId: product['id'].toString(),
                        //   ),
                        // );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.network(
                              product['image'] ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['title'] ?? 'Unnamed Item',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\$${product['price']}',
                                    style: TextStyle(
                                      color: darkBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  if (distance.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          distance,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Rentals Nearby',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(_showListView ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showListView = !_showListView;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _showListView
              ? Column(
                children: [
                  _buildFilterCard(),
                  Expanded(child: _buildNearbyItems()),
                ],
              )
              : _isLocationLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _customInfoWindowController.googleMapController =
                          controller;
                      setState(() {
                        _isMapLoading = false;
                      });
                    },
                    initialCameraPosition: _initialCameraPosition,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                    onTap: (position) {
                      _customInfoWindowController.hideInfoWindow!();
                    },
                    onCameraMove: (position) {
                      _customInfoWindowController.onCameraMove!();
                    },
                  ),
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 150,
                    width: 250,
                    offset: 50,
                  ),
                  if (_isMapLoading)
                    Container(
                      color: Colors.white,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),

          // Filter controls overlay for map view
          if (!_showListView && !_isLocationLoading && !_isMapLoading)
            Positioned(top: 16, left: 16, right: 16, child: _buildFilterCard()),
        ],
      ),
      floatingActionButton:
          !_showListView && !_isLocationLoading && !_isMapLoading
              ? FloatingActionButton(
                onPressed: () {
                  if (_currentPosition != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        15.0,
                      ),
                    );
                  }
                },
                backgroundColor: darkBlue,
                child: Icon(Icons.my_location),
              )
              : null,
    );
  }
}
