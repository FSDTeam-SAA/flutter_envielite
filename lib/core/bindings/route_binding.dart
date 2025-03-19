import 'package:get/get.dart';
import 'package:tour_guide/core/controller/admin_controller.dart';
import 'package:tour_guide/core/controller/audio_service.dart';
import 'package:tour_guide/helper/location_services.dart';

class RouteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController());
    // Get.lazyPut(() => TourController());
    Get.lazyPut(() => AudioService());
    // Get.lazyPut(() => LocationService());
    Get.put(LocationService(Get.find<AdminController>(), Get.find<AudioService>()));
  }
}

