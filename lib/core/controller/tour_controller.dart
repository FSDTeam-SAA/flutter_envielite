// // controllers/tour_controller.dart
// import 'package:get/get.dart';
// import 'package:tour_guide/helper/local_store_helper.dart';

// class TourController extends GetxController {
//   final RxMap<String, dynamic> tourData = RxMap({});
//   final String currentTour = 'wonderful_waterfalls';
//   final String currentLang = 'en';

//   @override
//   void onInit() {
//     loadTourData();
//     super.onInit();
//   }

//   Future<void> loadTourData() async {
//     tourData.value = await LocalStorageService.getTourData();
//   }

//   Future<void> refreshData() async {
//     await loadTourData();
//     update();
//   }

//   Future<void> togglePOIPlayed(int poiIndex) async {
//     final currentStatus = tourData[currentTour][currentLang]['pois'][poiIndex]['played'];
//     await LocalStorageService.updatePOIPlayedStatus(
//       currentTour,
//       currentLang,
//       poiIndex,
//       !currentStatus
//     );
//     await refreshData();
//   }

//   Future<void> updateIntroAudio(String newPath) async {
//     await LocalStorageService.updateAudioPath(
//       currentTour,
//       currentLang,
//       introPath: newPath
//     );
//     await refreshData();
//   }

//   Future<void> updatePOIAudio(int poiIndex, String newPath) async {
//     await LocalStorageService.updateAudioPath(
//       currentTour,
//       currentLang,
//       poiIndex: poiIndex,
//       poiAudioPath: newPath
//     );
//     await refreshData();
//   }

//   Map<String, dynamic> get currentTourData {
//     return tourData[currentTour][currentLang];
//   }

//   List<dynamic> get pois {
//     return currentTourData['pois'];
//   }
// }