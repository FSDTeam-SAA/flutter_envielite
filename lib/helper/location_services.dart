import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/admin_controller.dart';
import 'package:tour_guide/core/controller/audio_service.dart';
import 'package:tour_guide/model/tour_data.dart';

class LocationService extends GetxService {
  final AdminController _adminController;
  final AudioService _audioService; // Add AudioService as a dependency

  LocationService(this._adminController, this._audioService); // Constructor

  Stream<Position>? _locationStream;
  final RxBool _isTracking = false.obs;
  Timer? _proximityCheckTimer;

  // Reactive variable to store the current position
  final Rx<Position?> currentPosition = Rx<Position?>(null);

  // Track distance threshold (300 meters)
  static const double _poiRadius = 300; // meters

  // Track POIs that have already triggered an alert
  final Set<TourPOI> _triggeredPois = {};

  // Queue to manage multiple alerts
  final Queue<TourPOI> _alertQueue = Queue();
  final RxBool _isShowingAlert = false.obs;

  bool get isTracking => _isTracking.value;

  @override
  void onInit() {
    super.onInit();
    startTracking();
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  Future<void> startTracking() async {
    try {
      // Check permissions
      await _checkLocationPermissions();

      // Start updates
      _locationStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1, // Update every 5 meters
        ),
      );

      // Listen to location updates and update currentPosition
      _locationStream?.listen((position) {
        // Update the currentPosition reactive variable
        currentPosition.value = position;

        // Print current location
        debugPrint(
          'Current Location - Lat: ${position.latitude}, '
          'Lng: ${position.longitude}',
        );
      });

      // Start proximity check timer
      _proximityCheckTimer = Timer.periodic(Duration(seconds: 10), (
        timer,
      ) async {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
        );

        debugPrint("getPositionStream : $position");
        _checkPoiProximity(position);
      });

      _isTracking.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Location tracking failed: ${e.toString()}');
    }
  }

  void stopTracking() {
    _locationStream = null;
    _proximityCheckTimer?.cancel();
    _isTracking.value = false;
    _alertQueue.clear(); // Clear any pending alerts
    _triggeredPois.clear(); // Clear triggered POIs
    _isShowingAlert.value = false; // Reset alert state
    Get.closeAllSnackbars();
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions permanently denied';
    }
  }

  void _checkPoiProximity(Position position) {
    debugPrint("Checking POI proximity... $position");
    if (_adminController.poisStore.isEmpty) {
      debugPrint("No POIs available.");
      return;
    }
    // Debug: Print all POIs in poisStore
    debugPrint('POIs in poisStore: ${_adminController.poisStore}');

    // Check if the user has left any POIs
    _checkIfUserLeftPoi(position);

    for (final poi in _adminController.poisStore.values) {
      // Skip if this POI has already triggered an alert
      if (_triggeredPois.contains(poi)) {
        continue;
      }

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        poi.lat,
        poi.lng,
      );

      debugPrint("Distance to ${poi.name}: $distance meters");

      if (distance <= _poiRadius) {
        _showProximityAlert(poi);
        _triggeredPois.add(poi);
      }
    }
  }

  void _checkIfUserLeftPoi(Position position) {
    for (final poi in _triggeredPois.toList()) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        poi.lat,
        poi.lng,
      );

      // If the user is no longer within the radius, remove the POI from the triggered set
      if (distance > _poiRadius) {
        _triggeredPois.remove(poi);
        debugPrint("User left the proximity of ${poi.name}");
      }
    }
  }

  void _showProximityAlert(TourPOI poi) {
    _alertQueue.add(poi);
    _processAlertQueue();
  }

  void _processAlertQueue() {
    if (_isShowingAlert.value || _alertQueue.isEmpty) {
      return;
    }

    final poi = _alertQueue.removeFirst();
    _isShowingAlert.value = true;

    // Play audio using AudioService
    _audioService.playAudio(poi.audio);

    Get.snackbar(
      'Nearby POI Alert!',
      'You\'re within 300m of ${poi.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 5),
      isDismissible: false,
    ).future.then((_) {
      _isShowingAlert.value = false;
      _processAlertQueue(); // Process the next alert in the queue
    });
  }
}