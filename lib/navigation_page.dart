import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greenmalaysia/services/settings_service.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // --- STATE VARIABLES ---
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<dynamic> _places = []; // List of found recycling centers
  int _currentIndex = 0; // Which place is currently selected in the slide-up
  bool _isLoading = true;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // 1. Get GPS Location
  Future<void> _getUserLocation() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Get Position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // Once we have location, search for places
    _searchRecyclingPlaces();
  }

  // 2. Search Places using Google Places API
  Future<void> _searchRecyclingPlaces() async {
    if (_currentPosition == null) return;

    // Get Radius from Settings
    final settings = SettingsService(); // Access Singleton
    int radius = settings.navRadius;
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    String query = dotenv.env["RECYCLING_KEYWORD"] ?? "recycling|kitar+semula|recycle+center"; 

    // API Call
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=$radius'
        '&keyword=$query' // Specifically look for recycling
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _places = data['results'];
          _generateMarkers();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching places: $e");
      setState(() => _isLoading = false);
    }
  }

  // 3. Create Map Markers
  void _generateMarkers() {
    _markers.clear();
    for (int i = 0; i < _places.length; i++) {
      final place = _places[i];
      final loc = place['geometry']['location'];

      _markers.add(
        Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(loc['lat'], loc['lng']),
          infoWindow: InfoWindow(title: place['name']),
          onTap: () {
            // Tapping a marker selects it in the slide-up window
            setState(() => _currentIndex = i);
          },
        ),
      );
    }
  }

  // 4. Navigation Logic (Arrows)
  void _nextPlace() {
    if (_places.isEmpty) return;
    setState(() {
      if (_currentIndex < _places.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Loop back to start
      }
      _moveCameraToPlace();
    });
  }

  void _prevPlace() {
    if (_places.isEmpty) return;
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _places.length - 1; // Loop to end
      }
      _moveCameraToPlace();
    });
  }

  void _moveCameraToPlace() {
    final place = _places[_currentIndex];
    final loc = place['geometry']['location'];
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(loc['lat'], loc['lng'])),
    );
  }

  // 5. Open External Google Maps
  Future<void> _launchMapsApp() async {
    final place = _places[_currentIndex];
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];

    // Google Navigation Intent
    final Uri url = Uri.parse("google.navigation:q=$lat,$lng");

    if (!await launchUrl(url)) {
      // Fallback to web if app not installed
      final Uri webUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
      );
      launchUrl(webUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recycling Navigation")),
      body: Stack(
        children: [
          // A. THE MAP
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  markers: _markers,
                  myLocationEnabled: true, // Blue dot
                  onMapCreated: (controller) => _mapController = controller,
                ),

          // B. THE SLIDE UP WINDOW (Bottom Card)
          if (!_isLoading && _places.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Shrink to fit content
                  children: [
                    // --- Row 1: Arrows & Info ---
                    Row(
                      children: [
                        // Left Arrow
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _prevPlace,
                        ),

                        // Center Info
                        Expanded(
                          child: Column(
                            children: [
                              // Place Image (If available)
                              _buildPlacePhoto(_places[_currentIndex]),
                              const SizedBox(height: 8),

                              // Name
                              Text(
                                _places[_currentIndex]['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Address
                              Text(
                                _places[_currentIndex]['vicinity'] ??
                                    "Address not available",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Right Arrow
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: _nextPlace,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- Row 2: Navigate Button ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _launchMapsApp,
                        icon: const Icon(Icons.map),
                        label: const Text("Navigate with Google Maps"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // C. Empty State
          if (!_isLoading && _places.isEmpty)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black54,
                  child: const Text(
                    "No recycling centers found in radius.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper to build photo
  Widget _buildPlacePhoto(dynamic placeData) {
    if (placeData['photos'] != null && placeData['photos'].isNotEmpty) {
      String photoRef = placeData['photos'][0]['photo_reference'];
      String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
      String url =
          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=150&photoreference=$photoRef&key=$apiKey";

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          height: 80,
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    } else {
      return const Icon(Icons.recycling, size: 50, color: Colors.green);
    }
  }
}
