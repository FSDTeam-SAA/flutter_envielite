import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/bottom_nav_controller.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavController controller = Get.put(BottomNavController());

    return Scaffold(
      // appBar:AppBar(actions: [
      //   LayoutBuilder(
      //       builder: (context, constraints) {
      //         if (constraints.maxWidth >= 400) {
      //           // Web or larger screen layout
      //           return Row(
      //             children: [
      //               TextButton(
      //                 onPressed: () {
      //                   // Navigate to Home
      //                   Get.to(() => RouteSelectScreen());
      //                 },
      //                 child: const Text(
      //                   'Home',
      //                   style: TextStyle(color: Colors.white),
      //                 ),
      //               ),
      //               TextButton(
      //                 onPressed: () {
      //                   // Navigate to Admin
      //                   Get.to(() => AdminPanel());
      //                 },
      //                 child: const Text(
      //                   'Admin',
      //                   style: TextStyle(color: Colors.white),
      //                 ),
      //               ),
      //             ],
      //           );
      //         } else {
      //           return Container();
      //         }
      //       },
      //     ),

      // ],),
      body: Obx(() => controller.pages[controller.selectIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: "Admin",
            ),
          ],
        ),
      ),
    );
  }
}
