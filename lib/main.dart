import 'package:flutter/material.dart';
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/bindings/route_binding.dart';
import 'package:tour_guide/core/theme/theme.dart';
import 'package:tour_guide/presentation/screens/expired/expired_screen.dart';
import 'package:tour_guide/presentation/screens/nav_bar/bottom_navbar.dart';
import 'package:tour_guide/service/app_expire.dart';
import 'package:tour_guide/service/expiry_date.dart';

// Assuming you have this screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isAppExpired = AppExpire.isAppExpired();

  // setUrlStrategy(PathUrlStrategy());
  runApp(MyApp(isExpired: isAppExpired));
}

class MyApp extends StatelessWidget {
  final bool isExpired;
  const MyApp({super.key, required this.isExpired});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("isExpired : $isExpired");
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: RouteBinding(),
      // getPages: [
      //   GetPage(

      //     page: () => RouteSelectScreen(), // Assuming you have this screen
      //     binding: RouteBinding(),
      //   ),
      //   // admin panel
      //   GetPage(
      //     name: RouteNames.adminPanal,
      //     page: () => AdminPanel(),
      //     binding: RouteBinding(),
      //   ),

      //   GetPage(
      //     name: RouteNames.languageSelect,
      //     page: () => LanguageSelectScreen(),
      //     binding: RouteBinding(),
      //   ),
      //   GetPage(
      //     name: RouteNames.routeView,
      //     page: () => RouteViewScreen(),
      //     binding: RouteBinding(),
      //   ),

      //   GetPage(
      //     name: RouteNames.locationScreen,
      //     page: () => LocationScreen(),
      //     binding: RouteBinding(),
      //   ),
      // ],
      title: 'Tour Guide',
      theme: AppThemes.blackWhiteTheme,
      // home: RouteSelectScreen(),
      // home: BottomNavbar(),
      home: isExpired ? ExpiredScreen() : BottomNavbar(),
    );
  }
}
