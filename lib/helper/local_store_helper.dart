import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _key = 'tour_data';

  // Save entire tour data
  static Future<void> saveTourData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(data);
    await prefs.setString(_key, jsonData);
    debugPrint('Saved tour data: $jsonData'); // Debug statement
  }

  // Get full tour data
  static Future<Map<String, dynamic>> getTourData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    debugPrint('Loaded tour data: $data'); // Debug statement
    return data != null ? jsonDecode(data) : {};
  }

  // Update specific POI played status
  static Future<void> updatePOIPlayedStatus(
    String tourKey, 
    String language, 
    int poiIndex, 
    bool played
  ) async {
    final data = await getTourData();
    data[tourKey][language]['pois'][poiIndex]['played'] = played;
    await saveTourData(data);
  }

  // Update audio path for item
  static Future<void> updateAudioPath(
    String tourKey,
    String language, {
    String? introPath,
    int? poiIndex,
    String? poiAudioPath
  }) async {
    final data = await getTourData();
    
    if(introPath != null) {
      data[tourKey][language]['intro'] = introPath;
    }
    
    if(poiIndex != null && poiAudioPath != null) {
      data[tourKey][language]['pois'][poiIndex]['audio'] = poiAudioPath;
    }
    
    await saveTourData(data);
  }
}