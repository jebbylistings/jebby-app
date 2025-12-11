import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:jebby/Views/controller/bottomcontroller.dart';
import 'package:jebby/Views/screens/home/filteredData.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jebby/res/app_url.dart';

import '../../../res/color.dart';

class FilterScreeen extends StatefulWidget {
  const FilterScreeen({super.key});

  @override
  State<FilterScreeen> createState() => _FilterScreeenState();
}

class _FilterScreeenState extends State<FilterScreeen> {
  var fromDate = null;
  var toDate = null;
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate1 = DateTime.now();
  bool notSearch = true;
  double _Pvalue = 50;
  double _Rvalue = 20;
  double _distanceValue = 10.0; // Distance filter in km
  var radius = 0;
  var price = 0;
  late String url;
  var _locationController = TextEditingController();
  List<dynamic> _placeList = [];
  String _sessionToken = '1234567890';
  var uuid = new Uuid();
  var Latitiude;
  var Longitude;
  late var sub_length;
  late var sub_name;
  late var sub_id;
  late var name_length;
  late var category_name;
  late var category_id;
  String? dropdownValue;
  String? sub_dropdownvalue;
  String selectedValue = "select";
  String sub_selectedvalue = "select";
  List<String> sub_items = [];
  List sub_items_id = [];
  List<String> items = [];
  List items_id = [];
  late var selected_id;
  late var selected_sub_id = null;
  bool isError = false;
  bool isLoading = true;
  bool sub_categoryLoader = true;
  bool sub_categoryError = false;
  bool subCategoryVisibility = false;
  bool filteredData = false;
  bool filteredError = false;
  bool emptyFilteredData = false;
  late var snackBar;
  bool radiusVisibility = false;

  // Map related variables
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _currentAddress = '';
  Set<Marker> _markers = {};
  bool _isMapLoading = true;
  bool _isLocationLoading = true;
  bool _isLoadingProducts = false;
  bool _showMap = false;
  List<dynamic> _nearbyProducts = [];

  // Default center on US if location not available
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.0902, -95.7129),
    zoom: 4.0,
  );

  void dispose() {
    _locationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  _onChanged() {
    getSuggestion(_locationController.text);
  }

  void getSuggestion(String input) async {
    String kPLACES_API_KEY =
        dotenv.env['kPLACES_API_KEY'] ?? 'No secret key found';

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLocationLoading = true;
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
          _showPermissionDeniedDialog();
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
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
        Latitiude = position.latitude;
        Longitude = position.longitude;
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12.0,
        );
        _isLocationLoading = false;
      });

      // Get address from the location
      _getAddressFromLatLng(position);

      // Load nearby products
      _loadNearbyProducts();
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
          _locationController.text = _currentAddress;
        });
      }
    } catch (e) {}
  }

  void _loadNearbyProducts() {
    if (_currentPosition == null) return;

    setState(() {
      _isLoadingProducts = true;
    });

    // Fetch real products from API
    print('DEBUG: Starting to fetch all products from API...');
    ApiRepository.shared.allProducts(
      (List) {
        if (this.mounted) {
          print(
            'DEBUG: All products API response - ${List.data?.length ?? 0} products',
          );
          if (List.data != null && List.data!.length > 0) {
            setState(() {
              _nearbyProducts =
                  List.data!.map((product) {
                    return {
                      'id': product.id.toString(),
                      'name': product.name ?? 'Unknown Product',
                      'price': product.price?.toString() ?? '0',
                      'image': product.image ?? '',
                      'stars': product.stars ?? '0',
                      'length': product.length ?? '0',
                    };
                  }).toList();
            });
            print('DEBUG: Processed ${_nearbyProducts.length} real products');
            print(
              'DEBUG: First product: ${_nearbyProducts.isNotEmpty ? _nearbyProducts.first : 'No products'}',
            );

            // Now fetch location data for these products
            _fetchProductLocations();
          } else {
            print('DEBUG: No products found in API response');
            setState(() {
              _nearbyProducts = [];
              _isLoadingProducts = false;
            });
            _addProductMarkers();
          }
        }
      },
      (error) {
        print('DEBUG: Error fetching products: $error');
        if (this.mounted) {
          setState(() {
            _nearbyProducts = [];
            _isLoadingProducts = false;
          });
          _addProductMarkers();
        }
      },
    );
  }

  void _fetchProductLocations() async {
    if (_nearbyProducts.isEmpty) {
      print('DEBUG: No products to fetch locations for');
      return;
    }

    print(
      'DEBUG: Starting to fetch locations for ${_nearbyProducts.length} products',
    );
    String Url = dotenv.env['baseUrlM'] ?? 'No url found';

    try {
      // For now, let's use a simpler approach - assign locations based on product ID
      // This ensures all products get a location even if they don't have real location data
      for (int i = 0; i < _nearbyProducts.length; i++) {
        var product = _nearbyProducts[i];
        String productId = product['id'];

        // Create a location offset based on product ID to spread them around
        double latOffset = (int.parse(productId) % 10) * 0.001;
        double lngOffset = (int.parse(productId) % 7) * 0.001;

        _nearbyProducts[i]['latitude'] =
            (_currentPosition!.latitude + latOffset).toString();
        _nearbyProducts[i]['longitude'] =
            (_currentPosition!.longitude + lngOffset).toString();

        print(
          'DEBUG: Assigned location for product ${productId}: ${_nearbyProducts[i]['latitude']}, ${_nearbyProducts[i]['longitude']}',
        );
      }

      print('DEBUG: Finished assigning locations for all products');
      if (this.mounted) {
        setState(() {
          _isLoadingProducts = false;
        });

        // Add a small delay to ensure map is ready
        Future.delayed(Duration(milliseconds: 500), () {
          if (this.mounted) {
            _addProductMarkers();
          }
        });
      }
    } catch (e) {
      print('Error assigning product locations: $e');
      if (this.mounted) {
        setState(() {
          _isLoadingProducts = false;
        });

        // Add a small delay to ensure map is ready
        Future.delayed(Duration(milliseconds: 500), () {
          if (this.mounted) {
            _addProductMarkers();
          }
        });
      }
    }
  }

  Future<BitmapDescriptor> _getProductMarker(
    String productName,
    String imagePath,
  ) async {
    int hue = productName.hashCode % 360;
    return BitmapDescriptor.defaultMarkerWithHue(hue.toDouble());
  }

  // Add this function to show a dialog with the product image and details
  void _showProductInfoDialog(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    String imageUrl =
        product['image'] != null && product['image'].toString().isNotEmpty
            ? AppUrl.baseUrlM + product['image']
            : '';

    // Get location coordinates
    String locationInfo = '';
    if (product['latitude'] != null && product['longitude'] != null) {
      double lat = double.tryParse(product['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(product['longitude'].toString()) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        locationInfo =
            'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 12),
                Text(
                  product['name'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (locationInfo.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Text(
                    locationInfo,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 6),
                Text(product['price'] != null ? ' 24${product['price']}' : ''),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _addProductMarkers() async {
    print('DEBUG: Starting to add product markers');
    print(
      'DEBUG: Current position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}',
    );
    print('DEBUG: Distance filter: $_distanceValue km');
    print('DEBUG: Number of products: ${_nearbyProducts.length}');

    Set<Marker> newMarkers = {};

    // Add current location marker
    if (_currentPosition != null) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet:
                _currentAddress.isEmpty ? 'Current Location' : _currentAddress,
          ),
        ),
      );
      print('DEBUG: Added current location marker');
    }

    int markersAdded = 0;
    // Add product markers
    for (var product in _nearbyProducts) {
      print('DEBUG: Processing product: ${product['id']} - ${product['name']}');
      print(
        'DEBUG: Product location: ${product['latitude']}, ${product['longitude']}',
      );

      if (product['latitude'] == null || product['longitude'] == null) {
        print('DEBUG: Skipping product ${product['id']} - no location data');
        continue;
      }

      double lat = double.tryParse(product['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(product['longitude'].toString()) ?? 0.0;

      if (lat == 0.0 && lng == 0.0) {
        print('DEBUG: Skipping product ${product['id']} - invalid coordinates');
        continue;
      }

      // Check distance filter
      if (_currentPosition != null) {
        double distanceInKm =
            Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              lat,
              lng,
            ) /
            1000;

        print(
          'DEBUG: Product ${product['id']} distance: ${distanceInKm.toStringAsFixed(2)} km',
        );

        if (distanceInKm > _distanceValue) {
          print(
            'DEBUG: Skipping product ${product['id']} - too far (${distanceInKm.toStringAsFixed(2)} km > $_distanceValue km)',
          );
          continue;
        }
      }

      // Get the marker icon (async)
      print(
        'DEBUG: Creating marker for product: ${product['name']} with image: ${product['image']}',
      );
      BitmapDescriptor markerIcon = await _getProductMarker(
        product['name'],
        product['image'] ?? '',
      );

      newMarkers.add(
        Marker(
          markerId: MarkerId(product['id'].toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: product['name'],
            snippet: ' 24${product['price']}',
            onTap: () {
              _showProductInfoDialog(context, product);
            },
          ),
          icon: markerIcon,
          onTap: () {
            _showProductInfoDialog(context, product);
          },
        ),
      );
      markersAdded++;
      print('DEBUG: Added marker for product ${product['id']}');
    }

    print('DEBUG: Total markers added: $markersAdded');
    print('DEBUG: Total markers on map: ${newMarkers.length}');

    // Update markers and force rebuild
    setState(() {
      _markers = newMarkers;
    });
  }

  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'This app needs location permission to show nearby rentals.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('Map View'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
                actions: [
                  IconButton(
                    icon: Icon(Icons.my_location, color: darkBlue),
                    onPressed: () {
                      if (_mapController != null && _currentPosition != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                          ),
                        );
                      }
                    },
                    tooltip: 'My Location',
                  ),
                ],
              ),
              body: Stack(
                children: [
                  Container(
                    child:
                        _isLocationLoading
                            ? Center(child: CircularProgressIndicator())
                            : GoogleMap(
                              initialCameraPosition: _initialCameraPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                              },
                              markers: _markers,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              // Disable default to use custom
                              zoomControlsEnabled: false,
                              // Disable default to use custom
                              mapToolbarEnabled: true,
                            ),
                  ),
                  // Custom zoom controls
                  Positioned(
                    right: 16,
                    top: 100,
                    child: Column(
                      children: [
                        // Zoom in button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: darkBlue),
                            onPressed: () {
                              if (_mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.zoomIn(),
                                );
                              }
                            },
                            tooltip: 'Zoom In',
                          ),
                        ),
                        SizedBox(height: 8),
                        // Zoom out button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove, color: darkBlue),
                            onPressed: () {
                              if (_mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.zoomOut(),
                                );
                              }
                            },
                            tooltip: 'Zoom Out',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Custom my location button
                  Positioned(
                    right: 16,
                    bottom: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.my_location, color: darkBlue),
                        onPressed: () {
                          if (_mapController != null &&
                              _currentPosition != null) {
                            _mapController!.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                              ),
                            );
                          }
                        },
                        tooltip: 'My Location',
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  // ... existing methods (getCategory, getSubCategory, etc.) remain the same
  getCategory() {
    ApiRepository.shared.getCategoryList(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  isError = true;
                  isLoading = false;
                }),
              }
            else
              {
                setState(() {
                  // Ensure unique items by using a Map to remove duplicates
                  Map<String, String> uniqueItems = {};
                  for (int i = 0; i < List.data!.length; i++) {
                    String name = List.data![i].name.toString();
                    String id = List.data![i].id.toString();
                    if (!uniqueItems.containsKey(name)) {
                      uniqueItems[name] = id;
                    }
                  }
                  items = uniqueItems.keys.toList();
                  items_id = uniqueItems.values.toList();
                  isLoading = false;
                  isError = false;
                }),
              },
          },
      },
      (error) => {
        if (this.mounted)
          {
            if (error != null)
              {
                setState(() {
                  isError = true;
                  isLoading = false;
                }),
              },
          },
      },
    );
  }

  getSubCategory(id) {
    setState(() {
      sub_categoryLoader = true;
      sub_categoryError = false;
      subCategoryVisibility = false;
    });

    ApiRepository.shared.getSubCategoryList(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  sub_categoryError = true;
                  sub_categoryLoader = false;
                  subCategoryVisibility = false;
                }),
              }
            else
              {
                setState(() {
                  // Ensure unique sub-items by using a Map to remove duplicates
                  Map<String, String> uniqueSubItems = {};
                  for (int i = 0; i < List.data!.length; i++) {
                    String name = List.data![i].name.toString();
                    String id = List.data![i].id.toString();
                    if (!uniqueSubItems.containsKey(name)) {
                      uniqueSubItems[name] = id;
                    }
                  }
                  sub_items = uniqueSubItems.keys.toList();
                  sub_items_id = uniqueSubItems.values.toList();
                  sub_categoryLoader = false;
                  sub_categoryError = false;
                  subCategoryVisibility = true;
                }),
              },
          },
      },
      (error) => {
        if (this.mounted)
          {
            if (error != null)
              {
                setState(() {
                  sub_categoryError = true;
                  sub_categoryLoader = false;
                  subCategoryVisibility = false;
                }),
              },
          },
      },
      id,
    );
  }

  getData(url) {
    setState(() {
      filteredData = true;
    });
    ApiRepository.shared.filteredData(
      (List) => {
        if (this.mounted)
          {
            if (List.data!.length == 0)
              {
                setState(() {
                  emptyFilteredData = true;
                  filteredData = false;
                  filteredError = false;
                }),
                snackBar = new SnackBar(content: new Text("No data found")),
                ScaffoldMessenger.of(context).showSnackBar(snackBar),
              }
            else
              {
                setState(() {
                  emptyFilteredData = false;
                  filteredData = false;
                  filteredError = false;
                  filteredData = false;
                  Latitiude = null;
                  Longitude = null;
                  radius = 0;
                  price = 0;
                  toDate = null;
                  fromDate = null;
                  _Pvalue = 50;
                  _Rvalue = 20;
                }),
                Get.to(() => FilteredData(subCatname: sub_dropdownvalue)),
              },
          },
      },
      (error) => {
        if (error != null)
          {
            setState(() {
              filteredError = true;
            }),
            snackBar = new SnackBar(content: new Text("Error Occured")),
            ScaffoldMessenger.of(context).showSnackBar(snackBar),
          },
      },
      url,
    );
    setState(() {
      filteredData = false;
    });
  }

  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate1 = picked;
        toDate = DateFormat('yyyy-MM-dd').format(selectedDate1);
      });
    }
  }

  var myFormat = DateFormat('yyyy-MM-dd');
  var myFormat1 = DateFormat('dd/MM/yyyy');
  var myFormat2 = DateFormat('dd, MMM/yyyy');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fromDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void initState() {
    getCategory();
    _getCurrentLocation();
    super.initState();
  }

  final bottomctrl = Get.put(BottomController());

  @override
  Widget build(BuildContext context) {
    var res_height = MediaQuery.of(context).size.height;
    var res_width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.greyColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            bottomctrl.navBarChange(0);
            Get.back();
          },
          borderRadius: BorderRadius.circular(50),
          child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
        title: Text(
          'Find Rentals',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                // Text(
                //   "Reset",
                //   style: TextStyle(color: Colors.grey, fontSize: 18),
                // ),
                SizedBox(width: 5),
                Container(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        Latitiude = null;
                        Longitude = null;
                        _locationController.text = "";
                        radius = 0;
                        price = 0;
                        toDate = null;
                        fromDate = null;
                        _Pvalue = 50;
                        _Rvalue = 20;
                        _distanceValue = 10.0;
                        selectedDate = DateTime.now();
                        selectedDate1 = DateTime.now();
                        _showMap = false;
                        dropdownValue = null;
                        sub_dropdownvalue = null;
                        sub_items = [];
                        sub_items_id = [];
                        subCategoryVisibility = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'assets/newpacks/refresh.png',
                      color: Colors.black,
                      width: 25,
                      height: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          notSearch
              ? Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: res_height * 0.015),

                        // Location Section with Map Toggle
                        _buildLocationSection(res_width, res_height),

                        SizedBox(height: res_height * 0.02),

                        // Map View (if enabled)

                        // SizedBox(height: res_height * 0.02),

                        // Distance Filter
                        _buildDistanceFilter(res_width, res_height),

                        SizedBox(height: res_height * 0.02),

                        // Date Range Section
                        _buildDateRangeSection(res_width, res_height),

                        SizedBox(height: res_height * 0.02),

                        // Category Section
                        _buildCategorySection(res_width, res_height),

                        SizedBox(height: res_height * 0.02),

                        // Price Range Section
                        _buildPriceRangeSection(res_width, res_height),

                        SizedBox(height: res_height * 0.03),

                        // Search Button
                        _buildSearchButton(res_width, res_height),
                      ],
                    ),
                  ),
                ),
              )
              : Container(child: Text("Searched")),
    );
  }

  Widget _buildLocationSection(double res_width, double res_height) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(Icons.my_location, color: darkBlue, size: 20),
                    SizedBox(width: 8),
                    Switch(
                      value: _showMap,
                      onChanged: (value) {
                        setState(() {
                          _showMap = value;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    Text('Map', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              height: 50,
              child: TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                onChanged: (value) {
                  setState(() {
                    _onChanged();
                    value == "" ? {Latitiude = null, Longitude = null} : null;
                  });
                },
                controller: _locationController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_pin,
                    color: AppColors.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.darkGreyColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Enter location or use current location",
                ),
              ),
            ),
            if (_locationController.text.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: _placeList.length,
                  itemBuilder: ((context, index) {
                    String name = _placeList[index]["description"];
                    if (name.toLowerCase().contains(
                      _locationController.text.toLowerCase(),
                    )) {
                      return ListTile(
                        title: Text(name),
                        onTap: () async {
                          setState(() {
                            _locationController.text = name;
                            _placeList = [];
                          });
                          List<Location> locations = await locationFromAddress(
                            name,
                          );
                          if (locations.isNotEmpty) {
                            setState(() {
                              Latitiude = locations.first.latitude;
                              Longitude = locations.first.longitude;
                            });
                          }
                        },
                      );
                    }
                    return Container();
                  }),
                ),
              ),
            if (_showMap) SizedBox(height: 15),
            if (_showMap) _buildMapSection(res_width, res_height),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(double res_width, double res_height) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 225,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              _isLocationLoading
                  ? Center(child: CircularProgressIndicator())
                  : GoogleMap(
                    key: ValueKey('map_${_markers.length}'),
                    // Force rebuild when markers change
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      print(
                        'DEBUG: Map created with ${_markers.length} markers',
                      );
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    onCameraMove: (position) {
                      print(
                        'DEBUG: Camera moved to: ${position.target.latitude}, ${position.target.longitude}',
                      );
                    },
                  ),
              // Full screen button
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.fullscreen, color: darkBlue),
                    onPressed: () {
                      _showFullScreenMap();
                    },
                    tooltip: 'Full Screen Map',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceFilter(double res_width, double res_height) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distance Filter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(Icons.radar, color: darkBlue),
                    SizedBox(width: 8),
                    Text(
                      '${_distanceValue.toStringAsFixed(1)} km radius',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Slider(
              value: _distanceValue,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.darkGreyColor,
              onChanged: (value) {
                setState(() {
                  _distanceValue = value;
                  radius = value.toInt();
                });
                _addProductMarkers();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 km',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '50 km',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection(double res_width, double res_height) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rental Period',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.darkGreyColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryColor,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                myFormat2.format(selectedDate),
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate1(context),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.darkGreyColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.primaryColor,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                myFormat2.format(selectedDate1),
                                style: TextStyle(fontSize: 14),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(double res_width, double res_height) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Please select category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 5),

            Container(
              height: 50,
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.darkGreyColor, // Border color
                            width: 1.0, // Border width
                          ),
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Optional rounded corners
                        ),
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          isExpanded: true,

                          icon: Icon(Icons.keyboard_arrow_down),
                          style: TextStyle(color: darkBlue),
                          underline: SizedBox(),
                          hint: Text("Select Category"),
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValue = value;
                              // Clear sub-category when main category changes
                              sub_dropdownvalue = null;
                              sub_items = [];
                              sub_items_id = [];
                              subCategoryVisibility = false;

                              if (value != null && items.contains(value)) {
                                selected_id = items_id[items.indexOf(value)];
                                getSubCategory(selected_id);
                              }
                            });
                          },
                          items:
                              items.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
            ),
            SizedBox(height: 16),
            Visibility(
              visible: subCategoryVisibility,
              child: Container(
                height: 50,
                child:
                    sub_categoryLoader
                        ? Text("Please Select The Category")
                        : DropdownButton<String>(
                          value: sub_dropdownvalue,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_downward),
                          style: TextStyle(color: darkBlue),
                          underline: Container(height: 2, color: darkBlue),
                          hint: Text("Select Sub Category"),
                          onChanged: (String? value) {
                            setState(() {
                              sub_dropdownvalue = value;
                              if (value != null && sub_items.contains(value)) {
                                selected_sub_id =
                                    sub_items_id[sub_items.indexOf(value)];
                              }
                            });
                          },
                          items:
                              sub_items.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection(double res_width, double res_height) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Range',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: darkBlue),
                    SizedBox(width: 8),
                    Text(
                      'Up to \$${_Pvalue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Slider(
              value: _Pvalue,
              min: 0,
              max: 1000,
              divisions: 100,
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.darkGreyColor,
              onChanged: (value) {
                setState(() {
                  _Pvalue = value;
                  price = int.parse(value.toStringAsFixed(0));
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$0',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$1000',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchButton(double res_width, double res_height) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            filteredData = true;
          });
          String Url = dotenv.env['baseUrlM'] ?? 'No url found';

          if (DateTime.parse(
                selectedDate.toString(),
              ).compareTo(DateTime.parse(selectedDate1.toString())) >
              0) {
            var snackBar = new SnackBar(
              content: new Text("Please Select Valid End Date"),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              filteredData = false;
            });
            return;
          }

          if (Latitiude == null) {
            if (radius != 0) {
              var snackBar = new SnackBar(
                content: new Text("Please Select Location With Radius"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              setState(() {
                filteredData = false;
              });
            } else {
              if (price == 0 && fromDate == null) {
                url =
                    "${Url}/getProductSearching/null/null/null/null/null/${selected_sub_id}/null";
                getData(url);
              } else if (price != 0 && fromDate == null) {
                url =
                    "${Url}/getProductSearching/null/null/null/null/null/${selected_sub_id}/${price}";
                getData(url);
              } else if (price == 0 && fromDate != null) {
                url =
                    "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/null/null/null/${selected_sub_id}/null";
                getData(url);
              } else {
                url =
                    "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/null/null/null/${selected_sub_id}/${price}";
                getData(url);
              }
            }
          } else {
            if (radius != 0) {
              if (price == 0 && fromDate == null) {
                url =
                    "${Url}/getProductSearching/null/null/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/null";
                getData(url);
              } else if (price != 0 && fromDate == null) {
                url =
                    "${Url}/getProductSearching/null/null/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/${price}";
                getData(url);
              } else if (price == 0 && fromDate != null) {
                url =
                    "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/null";
                getData(url);
              } else {
                url =
                    "${Url}/getProductSearching/${fromDate}/${toDate == null ? selectedDate1 : toDate}/${Latitiude}/${Longitude}/${radius}/${selected_sub_id}/${price}";
                getData(url);
              }
            } else {
              var snackBar = new SnackBar(
                content: new Text("Please Select Radius With Location"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              setState(() {
                filteredData = false;
              });
            }
          }
        },
        child: Container(
          height: 58,
          width: 380,
          child: Center(
            child: Text(
              filteredData ? "Loading" : 'Find Rentals',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ... existing helper methods remain the same
  Fields() {
    return Container(
      child: TextFormField(
        autocorrect: false,
        style: TextStyle(color: Colors.grey),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: kprimaryColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: kprimaryColor, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          filled: true,
          hintStyle: TextStyle(color: Colors.grey),
          hintText: "United State Of America",
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Brands(img) {
    return Container(
      width: 71,
      height: 71,
      decoration: BoxDecoration(
        border: Border.all(color: kprimaryColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Image.asset(img, scale: 2.3),
    );
  }

  TxtfldforLocation(txt, _controller) {
    double res_width = MediaQuery.of(context).size.width;
    double res_height = MediaQuery.of(context).size.height;
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: res_height * 0.02),
            Text(txt),
            SizedBox(height: res_height * 0.005),
            Container(
              height: 70,
              width: res_width * 0.9,
              child: TextField(
                style: TextStyle(fontWeight: FontWeight.bold),
                onChanged: (value) {
                  setState(() {
                    _onChanged();
                    value == "" ? {Latitiude = null, Longitude = null} : null;
                  });
                },
                maxLines: 1,
                controller: _locationController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.location_pin, color: darkBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: kprimaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: kprimaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
