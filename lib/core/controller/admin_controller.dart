import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tour_guide/core/controller/audio_service.dart';
import 'package:tour_guide/helper/local_store_helper.dart';
import 'package:tour_guide/model/tour_data.dart';

class AdminController extends GetxController {
  final AudioService audioService = Get.put(AudioService());

  // Predefined routes and languages
  final List<String> predefinedRoutes = [
    'Wonderful Waterfalls',
    'Figure 8',
    'Quicksand Triangle',
    'The Volcano',
    'The Trifecta',
  ];

  final List<String> predefinedLanguages = [
    'English',
    'Spanish',
    'Japanese',
    'Hindi',
    'Arabic',
    'Chinese',
    'Ukrainian',
    'Russian',
  ];

  final Map<String, String> greetings = {
    'English': 'Hi',
    'Spanish': 'Hola',
    'Japanese': 'こんにちは',
    'Ukrainian': 'привіт',
    'Russian': 'Привет',
    'Chinese': '你好',
    'Hindi': 'नमस्ते',
    'Arabic': 'السلام عليكم',
  };

  // Reactive variables
  var selectedRoute = ''.obs;
  var selectedLanguage = ''.obs;
  var selectedIntroAudio = ''.obs;
  var pois = <TourPOI>[].obs;
  var poisStore = <String, TourPOI>{}.obs;
  var searchControllers = <TextEditingController>[].obs;
  var latControllers = <TextEditingController>[].obs;
  var lngControllers = <TextEditingController>[].obs;
  var audioPaths = <String>[].obs;
  var isRouteAndLanguageSelected = false.obs;

  // Search-related variables
  var searchQuery = ''.obs;
  var searchResults =
      <RxList<Map<String, dynamic>>>[].obs; // Store search results for each POI

  var searchLoadingStates = <RxBool>[].obs;

  Timer? _searchDebounce;

  bool isFilePickerActive = false;

  // Temporary list to store POIs before saving
  var tempPois = <TourPOI>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedRoute, (_) {
      checkSelection();
      loadSavedData();
    });
    ever(selectedLanguage, (_) {
      checkSelection();
      loadSavedData();
    });

    searchLoadingStates.value = List.generate(pois.length, (_) => false.obs);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  // Check Route and Langugae is select
  void checkSelection() {
    isRouteAndLanguageSelected.value =
        selectedRoute.value.isNotEmpty && selectedLanguage.value.isNotEmpty;
  }

  void checkPoints() {}

  // Load saved data from local storage
  void loadSavedData() async {
  if (selectedRoute.value.isEmpty || selectedLanguage.value.isEmpty) {
    clearTempData();
    return;
  }

  final data = await LocalStorageService.getTourData();
  final routeData = data[selectedRoute.value];
  final languageData = routeData?[selectedLanguage.value];

  if (languageData != null) {
    pois.value = (languageData['pois'] as List?)?.map((poi) => TourPOI.fromJson(poi)).toList() ?? [];
    selectedIntroAudio.value = languageData['intro'] ?? '';

    // Initialize search-related lists based on the number of POIs
    searchControllers.value = List.generate(pois.length, (_) => TextEditingController());
    latControllers.value = List.generate(pois.length, (_) => TextEditingController());
    lngControllers.value = List.generate(pois.length, (_) => TextEditingController());
    audioPaths.value = List.generate(pois.length, (_) => '');
    searchResults.value = List.generate(pois.length, (_) => <Map<String, dynamic>>[].obs);
    searchLoadingStates.value = List.generate(pois.length, (_) => false.obs);

    for (int i = 0; i < pois.length; i++) {
      searchControllers[i].text = pois[i].name;
      latControllers[i].text = pois[i].lat.toString();
      lngControllers[i].text = pois[i].lng.toString();
      audioPaths[i] = pois[i].audio;
    }
  } else {
    clearTempData();
  }
}

  // Search locations using OpenStreetMap API
  Future<void> searchLocations(String query, int index) async {
    if (query.length < 3) {
      searchResults[index].clear(); // Clear results for this POI
      return;
    }

    if (index >= searchLoadingStates.length || index >= searchResults.length) {
    debugPrint('Invalid index: $index');
    return;
  }

    searchLoadingStates[index].value = true;

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&accept-language=${selectedLanguage.value}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        searchResults[index].value =
            data
                .map<Map<String, dynamic>>(
                  (item) => {
                    'display_name': item['display_name'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                  },
                )
                .toList();
      } else {
        searchResults[index].clear(); // Clear results for this POI
      }
    } on SocketException catch (e) {
      searchResults[index].clear();
      Get.snackbar('Error', 'No internet connection: ${e.message}');
    } on http.ClientException catch (e) {
      searchResults[index].clear();
      Get.snackbar('Error', 'Failed to connect to the server: ${e.message}');
    } on TimeoutException catch (e) {
      searchResults[index].clear();
      Get.snackbar('Error', 'Request timed out: ${e.message}');
    } catch (e) {
      print("$e");
      searchResults[index].clear(); // Clear results for this POI
      Get.snackbar('Error', 'Failed to fetch search results: $e');
    } finally {
      searchLoadingStates[index].value = false;
    }
  }

  // Debounced search method
  void onSearchTextChanged(String query, int index) {
    if (index >= searchResults.length || index >= searchLoadingStates.length) {
      debugPrint('Invalid index: $index');
      return;
    }

    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchLocations(query, index);
    });
  }

  // Select a location from search results
  void selectLocation(Map<String, dynamic> location, int index) {
    if (index < 0 || index >= pois.length) {
      Get.snackbar('Error', 'Invalid POI index: $index');
      return;
    }

    debugPrint('Selected location: ${location['display_name']}');

    searchControllers[index].text = location['display_name'];

    latControllers[index].text = location['lat'].toString();
    lngControllers[index].text = location['lon'].toString();
    searchResults[index].clear();

    // Update the POI with the selected location
    pois[index] = TourPOI(
      lat: double.parse(location['lat']),
      lng: double.parse(location['lon']),
      audio: audioPaths[index],
      name: location['display_name'],
      // searchControllers[index].text.isNotEmpty
      //     ? searchControllers[index].text
      //     : 'Unnamed POI',
    );

    debugPrint(
      'Updated POI at index $index with location: ${location['display_name']}',
    );
  }

  // Clear search results
  void clearSearchResults() {
    searchResults.clear();
  }

  // Add the permission check function
  // Future<void> checkAndRequestPermissions() async {
  //   if (Platform.isAndroid) {
  //     final status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       Get.snackbar(
  //         'Permission Required',
  //         'Storage permission is needed to select audio files.',
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //       return;
  //     }
  //   }
  //   // For iOS, no runtime permissions are needed for file picking
  // }

  // Select intro audio file
  // Select intro audio file
  Future<void> selectIntroAudio() async {
    if (isFilePickerActive) return;
    isFilePickerActive = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        selectedIntroAudio.value = result.files.single.path!;
        debugPrint('Selected intro audio: ${selectedIntroAudio.value}');
      }
    } catch (e) {
      debugPrint('Error selecting intro audio: $e');
    } finally {
      isFilePickerActive = false;
    }
  }

  // Select audio file for a specific POI
  Future<void> selectAudio(int index) async {
    if (isFilePickerActive) return;
    isFilePickerActive = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.audio,
      );
      if (result != null) {
        audioPaths[index] = result.files.single.path!;
        pois[index].audio = result.files.single.path!;
        updateTourData();
      }
    } finally {
      isFilePickerActive = false;
    }
  }

  // Add point of interest
  void addPointOfInterest() {
  if (selectedRoute.value.isEmpty) {
    Get.snackbar(
      'Error',
      'Please select a route before adding a POI.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  // Add a new POI
  pois.add(TourPOI(lat: 0.0, lng: 0.0, audio: '', name: ''));

  // Add corresponding entries to search-related lists
  searchControllers.add(TextEditingController());
  latControllers.add(TextEditingController());
  lngControllers.add(TextEditingController());
  audioPaths.add('');
  searchResults.add(<Map<String, dynamic>>[].obs); // Add new RxList for search results
  searchLoadingStates.add(false.obs); // Add new loading state

  debugPrint('Added new POI. Total POIs: ${pois.length}');
}

  // Remove point of interest
  void removePointOfInterest(int index) {
    if (index < 0 || index >= pois.length) {
      Get.snackbar('Error', 'Invalid POI index: $index');
      return;
    }

    pois.removeAt(index);
    searchControllers.removeAt(index);
    latControllers.removeAt(index);
    lngControllers.removeAt(index);
    audioPaths.removeAt(index);
    searchResults.removeAt(index);

    searchLoadingStates.removeAt(index);

    debugPrint('Removed POI at index $index. Total POIs: ${pois.length}');
    updateTourData();
  }

  // Update tour data in local storage
  void updateTourData() async {
    final data = await LocalStorageService.getTourData();
    final routeData = data[selectedRoute.value] ?? {};
    // final languageData = routeData[selectedLanguage.value] ?? {};

    // Save POIs directly under the route
    // routeData['pois'] = pois.map((poi) => poi.toJson()).toList();

    // Save route intro audio
    routeData['intro'] = selectedIntroAudio.value;

    // Save language-specific data (intro audio)
    final languageData = routeData[selectedLanguage.value] ?? {};

    languageData['pois'] = pois.map((poi) => poi.toJson()).toList();
    languageData['intro'] = selectedIntroAudio.value;
    routeData[selectedLanguage.value] = languageData;

    data[selectedRoute.value] = routeData;

    debugPrint('Updated tour data: $data');
    await LocalStorageService.saveTourData(data);
  }

  // Save changes
  void saveChanges() {
    // Validate that all POIs have valid data
    for (int i = 0; i < pois.length; i++) {
      if (latControllers[i].text.isEmpty ||
          lngControllers[i].text.isEmpty ||
          searchControllers[i].text.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill out all fields for POI ${i + 1}.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    // Move POIs from temporary list to main list
    pois.addAll(tempPois);
    tempPois.clear();

    // Update the tour data
    updateTourData();

    Get.snackbar(
      'Success',
      'Changes saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void clearTempData() {
    pois.clear();
    selectedIntroAudio.value = '';
    searchControllers.clear();
    latControllers.clear();
    lngControllers.clear();
    audioPaths.clear();
    searchResults.clear();
  }

  // Helper method to get route data
  Future<Map<String, dynamic>> getRouteData(String routeName) async {
    if (selectedRoute.value.isEmpty) {
      debugPrint('No route selected');
      return {};
    }

    try {
      final data = await LocalStorageService.getTourData();
      return data[routeName] ?? {};
    } catch (e) {
      debugPrint('Error fetching route data: $e');
      return {};
    }
  }

  // Fetch intro audio (language intro audio takes precedence over route intro audio)
  Future<String> getIntroAudio() async {
    if (selectedRoute.value.isEmpty) {
      debugPrint('No route selected');
      return '';
    }

    final data = await LocalStorageService.getTourData();
    final routeData = data[selectedRoute.value];

    if (routeData != null) {
      // Check if the selected language has its own intro audio
      final languageData = routeData[selectedLanguage.value];
      if (languageData != null && languageData['intro'] != null) {
        debugPrint('Fetched language intro audio: ${languageData['intro']}');
        return languageData['intro'];
      }

      // Fallback to the route's intro audio
      final routeIntroAudio = routeData['intro'] ?? '';
      debugPrint('Fetched route intro audio: $routeIntroAudio');
      return routeIntroAudio;
    }

    debugPrint('No route data found for selected route');
    return '';
  }
}
