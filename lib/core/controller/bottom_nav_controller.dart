import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/presentation/screens/admin/admin_panal.dart';
import 'package:tour_guide/presentation/screens/users/route_select_screen.dart';

class BottomNavController extends GetxController {
  var selectIndex = 0.obs;

  final List<Widget> pages = [
    RouteSelectScreen(),
    AdminPanel()
  ];

  void changeTab(int index) {
    selectIndex.value = index;
  }
}