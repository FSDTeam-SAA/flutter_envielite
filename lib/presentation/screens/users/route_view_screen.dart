import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/admin_controller.dart';
import 'package:tour_guide/core/controller/audio_service.dart';
import 'package:tour_guide/helper/location_services.dart';
import 'package:tour_guide/model/tour_data.dart';

class RouteViewScreen extends StatelessWidget {
  final LocationService _locationService = Get.find();
  final AdminController _adminController = Get.find();
  final AudioService _audioService = Get.find();

  RouteViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route: ${_adminController.selectedRoute.value}'),
        centerTitle: true, // Center the title for better UI
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return FutureBuilder(
      future: _adminController.getRouteData(
        _adminController.selectedRoute.value,
      ),
      builder: (context, snapshot) {
        // Show a loading indicator while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading route data...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Show an error message if data fetching fails
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Something is wrong',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry fetching data
                    _adminController.loadSavedData();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final routeData = snapshot.data ?? {};
        final langData = routeData[_adminController.selectedLanguage.value];

        print("Check language Data -> $langData");

        // Show a friendly message if no data is available
        if (routeData.isEmpty || langData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No data available for this route and language.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back or perform another action
                    Get.back();
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        // Display the tour details if data is available
        return _buildTourDetails(langData);
      },
    );
  }

  Widget _buildTourDetails(Map<String, dynamic> langData) {
    // Prepare the list of POIs directly from the route data
    final pois =
        (langData['pois'] as List?)?.map((poiData) {
          return TourPOI.fromJson(poiData);
        }).toList() ??
        [];

    // Handle case where there are no POIs
    if (pois.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No points of interest available for this route.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    // Update the controller's POIs map
    _adminController.poisStore.clear();
    for (final poi in pois) {
      _adminController.poisStore[poi.name] = poi;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Points of Interest',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // play and pause audio and other featues show in here
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final currentPosition = _locationService.currentPosition.value;
              final isTracking = _locationService.isTracking;

              return ListView.builder(
                itemCount:
                    pois.isEmpty ? 0 : pois.length * 2 - 1, // Handle empty case
                itemBuilder: (context, index) {
                  if (pois.isEmpty) return const SizedBox.shrink();

                  // Rest of your ListView.builder logic
                  if (index.isEven) {
                    final poiIndex = index ~/ 2;
                    final poi = pois[poiIndex];
                    final distance =
                        isTracking && currentPosition != null
                            ? Geolocator.distanceBetween(
                              currentPosition.latitude,
                              currentPosition.longitude,
                              poi.lat,
                              poi.lng,
                            )
                            : null;

                    final isNearby =
                        isTracking && distance != null && distance <= 300;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      color: isNearby ? Colors.blue[50] : Colors.white,
                      child: ListTile(
                        title: Text(
                          poi.name,
                          style: TextStyle(
                            fontWeight:
                                isNearby ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lat: ${poi.lat}, Lng: ${poi.lng}'),
                            if (isTracking && distance != null)
                              Text(
                                'Distance: ${distance.toStringAsFixed(2)} meters',
                              ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.location_on,
                          color: isNearby ? Colors.blue : Colors.grey,
                        ),
                      ),
                    );
                  }
                  // If the index is odd, show the distance between two POIs
                  else {
                    final firstPoiIndex = (index - 1) ~/ 2;
                    if (firstPoiIndex >= pois.length - 1) {
                      return const SizedBox.shrink();
                    }
                    final firstPoi = pois[firstPoiIndex];
                    final secondPoi = pois[firstPoiIndex + 1];
                    final distanceBetweenPois = Geolocator.distanceBetween(
                      firstPoi.lat,
                      firstPoi.lng,
                      secondPoi.lat,
                      secondPoi.lng,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Distance to next POI: ${distanceBetweenPois.toStringAsFixed(2)} meters',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
