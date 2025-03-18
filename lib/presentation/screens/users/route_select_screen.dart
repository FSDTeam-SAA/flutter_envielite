import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/admin_controller.dart';
import 'package:tour_guide/presentation/screens/users/language_select_screen.dart';

class RouteSelectScreen extends StatelessWidget {
  const RouteSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tour Guide')),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth < 600 ? double.infinity : 600,
              child:
                  controller.predefinedRoutes.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'No routes available. Please check back later.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.builder(
                          itemCount: controller.predefinedRoutes.length,
                          itemBuilder: (context, index) {
                            final route = controller.predefinedRoutes[index];
                            debugPrint('Route: $route');
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle route selection
                                  controller.selectedRoute.value = route;
                                  Get.to(() => LanguageSelectScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                child: Text(route),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}
